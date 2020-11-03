% Forecasts expected realized future volatility via a GARCH (1, 1) model

clear;

% loading in temp file 
load DATA swapRates swapData

%% Swap Log Return 

[T,N] = size(swapData);
returns = zeros(T-1, N-1);      % initialize the size of return matrix 

% iterate through each swap rate
for n = 1:N-1                                                               
    swap = swapData{:,n+1};  % start at the second columns, first is dates
    
    % compute the log return for each term 
    returns(:,n) = log(swap(2:end)) - log(swap(1:end-1));
end  

%% Volatility Model Initialization

%-------------------------------------------------------------
%         Estimate Garch at each date t (starting in)
%        https://www.mathworks.com/help/econ/garch.html
%-------------------------------------------------------------

% Garch(1,1) model with p=1 and q=1                                         (eGARCH suffers cond. var positivity error)
model = garch('ARCHLags', 1, 'GARCHLags', 1, 'Distribution', ...
    'Gaussian', 'Offset', NaN); 
% model = arima('AR', NaN, 'Distribution', 'Gaussian', 'Variance', ...
%     garch(1,1));
options = optimoptions(@fmincon, 'Display' , 'off', 'Diagnostics', ...
    'off', 'Algorithm', 'sqp', 'TolCon', 1e-7);

nTrials = 100;                     % number of independent random trials
horizon = 504;                     % VaR forecast horizon (# observations)

m1 = [3, 6, 12, 24];               % swap terms 3m; 6m; 12m; 24m
mm = m1*21;                        % re-index for trading days

rollWindow = 2654;                 % train first 2137 sample data 

%-------------------------------------------------------------
SigmaF = zeros(T-rollWindow-1,12);  % initialize the size of the matrix 
SminF  = zeros(T-rollWindow-1,12); 
SmaxF  = zeros(T-rollWindow-1,12); 
%-------------------------------------------------------------

%% Monte Carlo Simulator (Volatility Model)

tic     % time convention    
for t = 1:T-rollWindow-1                   
    propIndex = 1;           % index for tracking column position 
    
    for i = [1, 2, 3]        % index position of the 2y; 5y; 10y swap tenor
        
        % presample innovations (returns matrix)
        r = returns(1:t+rollWindow, i);
        
        % fitting the conditional variance model GARCH to data 
        EstMdl = estimate(model, r, 'options', options, 'Display', 'off');  % surpress display of outputs for fit
        
        % infer conditional variances from corresponding models
        v0 = infer(EstMdl, r);
               
        rng default; % RNG control for reproducibility
        
        % simualte nTrials of the GARCH(1,1) model with horizon obs.
        vSim = simulate(EstMdl, horizon, 'NumPaths', nTrials, 'E0', ...
            r(end), 'V0', v0(end));
        
        % sqrt to get conditional standard deviations
        simSTD = sqrt(vSim);                                                
        
        % compute the average cond. variance across rows
        SS = mean(simSTD, 2);                                               % creates a horizon-by-1 matrix
        
        %-------------- 95% confidence bounds ----------------
        Smin = prctile(simSTD, 2.5, 2);                                     % calc. 2.5th percentile along rows
        Smax = prctile(simSTD, 97.5, 2);                                    % calc. 97.5th percentile along rows
        %-----------------------------------------------------
        
        % iterate through the swap terms by modifying the index
        for j=1:4        % mm = [63 126 252 504]       l  
            SigmaF(t,propIndex) = mean(SS(1:mm(j)));                        % assign by tenor then term                                             
            SminF(t,propIndex)  = mean(Smin(1:mm(j)));                      %    e.g. 2y3m, 2y6m, ...
            SmaxF(t,propIndex)  = mean(Smax(1:mm(j)));
            propIndex = propIndex + 1;                                      % increment the column index 
        end
        
    end
    
    % sanity checking for runtime process
    if mod(t, 50) == 0
        fprintf('t value is %d ...\n', t);
        toc
    end
end
% approx. 4.5 hours in runtime for 10000 sims
% approx. 15 minutes in runtime for 100 sims

%% Normalzing GARCH Measures 

%----- Annualize Volatility------------
SigA = SigmaF*sqrt(252)*100;
LB   = SminF*sqrt(252)*100;
UB   = SmaxF*sqrt(252)*100;
%--------------------------------------

% new table names and dates for the forecasted region 
newNames = tableNames(); newDates = swapData{rollWindow+2:end, 1};

% Modifying matrix to table data structure
SigmaFA = array2table(SigmaF, 'VariableNames', newNames);
LBFA = array2table(SminF, 'VariableNames', newNames);
UBFA = array2table(SmaxF, 'VariableNames', newNames);
SigmaFA.date = newDates; LBFA.date = newDates; UBFA.date = newDates;

SigA = array2table(SigA, 'VariableNames', newNames);
LB = array2table(LB, 'VariableNames', newNames);
UB = array2table(UB, 'VariableNames', newNames);
SigA.date = newDates; LB.date = newDates; UB.date = newDates;

% exporting GARCH forecasts
save('Temp/FSigmaF.mat','SigmaFA','LBFA','UBFA');
disp('Daily vol file has been created...');

save('Temp/SigA.mat','SigA','LB','UB');
disp('Annualized vol file has been created...');

%%

% --------------------------------------------------------------------
%   Helper Functions
% --------------------------------------------------------------------

function array = tableNames()
    tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
    terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 1y; 2y

    index = 1; 
    array = ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"];   % declare memory for string array
    
    for i = 1:length(tenors)
        for j = 1:length(terms)
            name = strcat("USSV", terms(j), tenors(i), "Curncy");           % creating the Bloomberg name ref
            array(index) = name; 
            index = index + 1;                                              % increment the index for name array
        end
    end
end
