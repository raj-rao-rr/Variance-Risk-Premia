% Forecasts expected realized future volatility via a GARCH (1, 1) model

clearvars -except root_dir;

% loading in temp file 
load DATA swaps iv


%% Swap Log Return 

[T, N] = size(swaps);
returns = zeros(T-1, N-1);      % initialize the size of return matrix 

% iterate through each swap rate
for n = 1:N-1  
    
    % compute the log return for each term 
    returns(:, n) = log(swaps{2:end, n+1}) - log(swaps{1:end-1, n+1});
    
end  

%% Volatility Model Initialization

%-------------------------------------------------------------
%         Estimate Garch at each date t (starting in)
%        https://www.mathworks.com/help/econ/garch.html
%-------------------------------------------------------------

% initialize a GARCH variance model (Default distribution is Gaussian)                    
Mdl1 = garch('GARCHLags', 1, 'ARCHLags', 1, 'Distribution', 'Gaussian');
Mdl2 = egarch('GARCHLags', 1, 'ARCHLags', 1, 'LeverageLags', 1, ...
    'Distribution', 'Gaussian');
Mdl3 = gjr('GARCHLags', 1, 'ARCHLags', 1, 'Distribution', 'Gaussian');

nTrials = 100;                     % number of independent random trials
horizon = 506;                     % VaR forecast horizon (# observations)

m1 = [3, 6, 12, 24];               % swap terms 3m; 6m; 12m; 24m
mm = m1*21+1;                      % re-index for trading days (1m = 21d)

t0 = 2500;                         % determine rolling window to train       

% initialize the size of the matrix for min, max and median estimates
SigmaF = zeros(T-t0-1, 12);  
SminF  = zeros(T-t0-1, 12); 
SmaxF  = zeros(T-t0-1, 12); 

%% Monte Carlo Simulator (Volatility Model)

fprintf('2. Perform Monte Carlo SImulator for GARCH vol model\n')

tic     % time convention    
for t = 1:T-t0-1                  
    propIndex = 1;           % index for tracking column position 
    
    % sanity checking for runtime process
    if mod(t, 100) == 0
        fprintf('\tt value is %d, %d timestamps to go...\n', t, T-t0-1-t);
    end
    
    for i = [1, 2, 3]        % index position of the 2y, 5y, 10y tenor
        
        % log returns vector for accompanying swap
        r = returns(1:t+t0, i);

        % fitting the conditional variance model to data 
        % we suppress the display of outputs for each fit
        [EstMdl, EstParamCov, ~, ~]= estimate(Mdl2, r, 'Display', 'off');  
        
        % infer conditional variances from corresponding model(s)
        preVar = diag(EstParamCov);
        preInv = r - Mdl2.Offset;
        
        [v0, ~] = infer(EstMdl, r, 'E0', preInv(end), 'V0', preVar(end));   
        
        rng default             % For reproducibility
        
        % simulated residuals (pre-innovations) 
        res = r - EstMdl.Offset;
        
        % simulate nTrials of the conditional variance model
        [V, Y] = simulate(EstMdl, horizon, 'NumPaths', nTrials, ...
            'E0', res(end), 'V0', v0(end));        
        
        % we take the square root of our conditional variance to 
        % compute the standard deviation, a.ka. realized volatility                                    
        vol = sqrt(V);
        
        % compute the average cond. variance across rows
        SS = mean(vol(2:end, :), 2);                                        % creates a horizon-by-1 matrix
        
        %-------------- 95% confidence bounds ----------------
        Smin = prctile(vol(2:end, :), 2.5, 2);                              % calc. 2.5th percentile along rows
        Smax = prctile(vol(2:end, :), 97.5, 2);                             % calc. 97.5th percentile along rows
        %-----------------------------------------------------
        
        % iterate through the swap terms by modifying the index
        for j=1:4        % mm = [64 127 253 505]         
            SigmaF(t, propIndex) = mean(SS(1:mm(j)));                       % assign by tenor then term                                             
            SminF(t, propIndex)  = mean(Smin(1:mm(j)));                     %    e.g. 2y3m, 2y6m, 2y1y, 2y2y
            SmaxF(t, propIndex)  = mean(Smax(1:mm(j)));
            
            % iteratively increment the column index 
            propIndex = propIndex + 1;                                       
        end
                
        
    end
    
end
toc

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
fprintf('2.5 Annualized vol file has been created.\n');
