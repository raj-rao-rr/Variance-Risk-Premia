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
%          Estimate Garch at each date t (starting in)
%    https://www.mathworks.com/help/econ/garch.html
%-------------------------------------------------------------

% Garch(1,1) model with p=1 and q=1                                         (eGARCH suffers cond. var positivity error)
model = garch('ARCHLags', 1, 'GARCHLags', 1, 'Offset', 0, ...
    'Distribution', 'Gaussian'); 

nTrials = 100;                     % number of independent random trials
horizon = 504;                     % VaR forecast horizon (# observations)

m1 = [3, 6, 12, 24];               % swap terms 3m; 6m; 12m; 24m
mm = m1*21;                        % re-index for trading days

rollWindow = 2137;                 % train first # sample data 

%-------------------------------------------------------------
SigmaF = zeros(T-rollWindow-1,12);  % initialize the size of the matrix 
SminF  = zeros(T-rollWindow-1,12); 
SmaxF  = zeros(T-rollWindow-1,12); 
%-------------------------------------------------------------

%% Monte Carlo Simulator (Volatility Model)

tic     % time convention 
for t = 1:T-rollWindow-1                      
    propIndex = 1;           % index for tracking column position 
    
    for i = [1, 2, 3]  % index position of the 2y; 5y; 10y swap rate
        
        % presample innovations (returns matrix)
        r = returns(t:t+rollWindow, i);
        
        % fitting the conditional variance model GARCH to data 
        EstMdl = estimate(model, r, 'Display', 'off');                      % surpress display of outputs for fit
        
        rng default; % RNG control for reproducibility
        
        % infer conditional variances from corresponding models
        v0 = infer(EstMdl, r);
 
        % simualte nTrials of the GARCH(1,1) model with horizon obs. 
        vSim = simulate(EstMdl, horizon, 'NumPaths', nTrials, ...
            'E0', r, 'V0', v0);                                             % creates a horizon-by-nTrials matrix
        
        % compute the average cond. variance across rows
        SS = mean(vSim, 2);                                                 % creates a horizon-by-1 matrix

        %-------------- 95% confidence bounds ----------------
        Smin = prctile(vSim, 2.5, 2);                                       % calc. 2.5th percentile along rows
        Smax = prctile(vSim, 97.5, 2);                                      % calc. 97.5th percentile along rows
        %-----------------------------------------------------
        
        % iterate through the swap terms by modifying the index
        for j=1:4        % mm = [65 128 254 506]       l  
            SigmaF(t,propIndex) = mean(SS(1:mm(j)), 1);                     % assign by tenor then term                                             
            SminF(t,propIndex)  = mean(Smin(1:mm(j)), 1);                   %    e.g. 2y3m, 2y6m, ...
            SmaxF(t,propIndex)  = mean(Smax(1:mm(j)), 1);
            propIndex = propIndex + 1;                                      % increment the column index 
        end

    end
    
    % sanity checking for runtime process (visual que)
    if mod(t, 50) == 0
        fprintf('t value is %d ...\n', t);
    end
end
toc % approx. 4.5 hours in runtime for 10000 sims
    % approx. 15 minutes in runtime for 100 sims

%% Normalzing GARCH Measures 

%----- Annualize Volatility------------
SigA = SigmaF*sqrt(252)*100;
LB   = SminF*sqrt(252)*100;
UB   = SmaxF*sqrt(252)*100;
%--------------------------------------

% Modifying matrix to table data structure
SigmaFA = array2table(SigmaF, 'VariableNames', tableNames());
SigmaFA.date = swapData{rollWindow+2:end, 1};
LBFA = array2table(SminF, 'VariableNames', tableNames());
LBFA.date = swapData{rollWindow+2:end, 1};
UBFA = array2table(SmaxF, 'VariableNames', tableNames());
UBFA.date = swapData{rollWindow+2:end, 1};

SigA = array2table(SigA, 'VariableNames', tableNames());
SigA.date = swapData{rollWindow+2:end, 1};
LB = array2table(LB, 'VariableNames', tableNames());
LB.date = swapData{rollWindow+2:end, 1};
UB = array2table(UB, 'VariableNames', tableNames());
UB.date = swapData{rollWindow+2:end, 1};

% exporting GARCH forecasts
save('Temp/FSigmaF.mat','SigmaFA','LBFA','UBFA');
disp('Daily vol file has been created...');

save('Temp/SigA.mat','SigA','LB','UB');
disp('Annualized vol file has been created...');

%% Sample Plot

% figure('visible', 'on'); 
% subplot(2,1,1); hold on; 
% plot(UB{:, 13}, UB{:, 1}, 'DisplayName', 'Upper Bounds')
% plot(SigA{:, 13}, SigA{:, 1}, 'DisplayName', '2y3m GARCH Vol')
% plot(LB{:, 13}, LB{:, 1}, 'DisplayName', 'Lower Bound')
% legend('show', 'location', 'northwest'); hold off; 

% subplot(2,1,2);
% plot(swapData{rollWindow+2:end,1}, returns(rollWindow+1:end,1), ...
%     'DisplayName', 'Log Returns')
% legend('show', 'location', 'northwest')

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
