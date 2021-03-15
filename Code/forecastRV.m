% Forecasts expected realized future volatility via a GARCH (1, 1) model

clear;

% loading in temp file 
load DATA swaps iv

%% Swap Log Return 

[T, N] = size(swaps);
returns = zeros(T-1, N-1);      % initialize the size of return matrix 

% iterate through each swap rate
for n = 1:N-1                                                               
    swap = swaps{:, n+1};  % start at the second columns, first is date
    
    % compute the log return for each term 
    returns(:, n) = log(swap(2:end)) - log(swap(1:end-1));
end  

%% Volatility Model Initialization

%-------------------------------------------------------------
%         Estimate Garch at each date t (starting in)
%        https://www.mathworks.com/help/econ/garch.html
%-------------------------------------------------------------

% initialize a GARCH variance model (Default distribution is Gaussian)                    
Mdl1 = garch(1, 1);
Mdl2 = egarch(1, 1);
Mdl3 = gjr(1, 1);

% % set the options for forecast model optimization
% options = optimoptions(@fmincon, 'Display' , 'off', 'Diagnostics', ...
%     'off', 'Algorithm', 'sqp', 'TolCon', 1e-7);
        
nTrials = 5000;                    % number of independent random trials
horizon = 506;                     % VaR forecast horizon (# observations)

m1 = [3, 6, 12, 24];               % swap terms 3m; 6m; 12m; 24m
mm = m1*21+2;                      % re-index for trading days              (1 month = 21 days)

t0 = 2045-1;               % start forecasting at 01/23/1997       

% initialize the size of the matrix for min, max and median estimates
SigmaF = zeros(T-t0-1, 12);  
SminF  = zeros(T-t0-1, 12); 
SmaxF  = zeros(T-t0-1, 12); 

%% Monte Carlo Simulator (Volatility Model)

tic     % time convention    
for t = 1:1%T-t0-1                  
    propIndex = 1;           % index for tracking column position 
    
    % sanity checking for runtime process
    if mod(t, 50) == 0
        fprintf('t value is %d, %d to go...\n', t, T-t0-1-t);
        toc
    end
    
    for i = [1, 2, 3]        % index position of the 2y, 5y, 10y tenor
        
        % presample innovations (returns matrix)
        r = returns(1:t+t0, i);
        
        % fitting the conditional variance model to data 
        % we suppress the display of outputs for each fit
        EstMdl = estimate(Mdl2, r, 'Display', 'off');  
        
        % infer conditional variances from corresponding models
        v0 = infer(EstMdl, r);   
        
        rng default             % For reproducibility
        
        % standardize the simulated innovations 
        res = r - EstMdl.Offset;
        
        % simulate nTrials of the conditional variance model
        [vSim, pRets] = simulate(EstMdl, horizon, 'NumPaths', nTrials, ...
            'E0', res(end), 'V0', v0(end));        
        
        % we take the square root of our conditional variance to 
        % compute the standard deviation, a.ka. realized volatility                                    
        vol = sqrt(vSim);
        
        % compute the average cond. variance across rows
        SS = mean(vol, 2);                                                  % creates a horizon-by-1 matrix
        
        %-------------- 95% confidence bounds ----------------
        Smin = prctile(vol, 2.5, 2);                                        % calc. 2.5th percentile along rows
        Smax = prctile(vol, 97.5, 2);                                       % calc. 97.5th percentile along rows
        %-----------------------------------------------------
        
        % iterate through the swap terms by modifying the index
        for j=1:4        % mm = [64 127 253 505]         
            SigmaF(t, propIndex) = mean(SS(1:mm(j)));                       % assign by tenor then term                                             
            SminF(t, propIndex)  = mean(Smin(1:mm(j)));                     %    e.g. 2y3m, 2y6m, 2y1y, 2y2y
            SmaxF(t, propIndex)  = mean(Smax(1:mm(j)));
            propIndex = propIndex + 1;                                      % increment the column index 
        end
        
    end
    
    % Values for checking against implied measures
    disp('The realized vs implied volatility')
    disp(swaps{t0+2, 1})
    disp(SigmaF(1, :)*sqrt(252)*100) 
    disp(iv{iv{:, 1} == swaps{t0+2, 1}, 2:end})
end

%% Normalzing GARCH Measures 

%----- Annualize Volatility------------
SigA = SigmaF*sqrt(252)*100;
LB   = SminF*sqrt(252)*100;
UB   = SmaxF*sqrt(252)*100;
%--------------------------------------

% new table names and dates for the forecasted region 
newNames = ["USSV0C2 CURNCY", "USSV0F2 CURNCY", "USSV012 CURNCY",...
    "USSV022 CURNCY", "USSV0C5 CURNCY", "USSV0F5 CURNCY", "USSV015 CURNCY",...
    "USSV025 CURNCY", "USSV0C10 CURNCY", "USSV0F10 CURNCY", "USSV0110 CURNCY",...
    "USSV0210 CURNCY"];
newDates = swaps{t0+2:end, 1};

% Modifying matrix to table data structure
SigmaFA = array2table(SigmaF, 'VariableNames', newNames);
LBFA = array2table(SminF, 'VariableNames', newNames);
UBFA = array2table(SmaxF, 'VariableNames', newNames);
SigmaFA.date = newDates; LBFA.date = newDates; UBFA.date = newDates;

SigA = array2table(SigA, 'VariableNames', newNames);
LB = array2table(LB, 'VariableNames', newNames);
UB = array2table(UB, 'VariableNames', newNames);
SigA.date = newDates; LB.date = newDates; UB.date = newDates;

% reordering the date column and bringing it to the top
SigmaFA = [SigmaFA(:, end), SigmaFA(:, 1:end-1)];
LBFA = [LBFA(:, end), LBFA(:, 1:end-1)];
UBFA = [UBFA(:, end), UBFA(:, 1:end-1)];
SigA = [SigA(:, end), SigA(:, 1:end-1)];
LB = [LB(:, end), LB(:, 1:end-1)];
UB = [UB(:, end), UB(:, 1:end-1)];

% exporting GARCH forecasts
save('Temp/FSigmaF.mat','SigmaFA','LBFA','UBFA');
fprintf('Daily vol file has been created.\n');

save('Temp/SigA.mat','SigA','LB','UB');
fprintf('Annualized vol file has been created.\n');
