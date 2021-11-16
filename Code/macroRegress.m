% Regress change in implied volatilites against macroeconomic variables 

clearvars -except root_dir;

% loading in economic and volatility data
load DATA yeildCurve ecoMap iv fedfunds vrp ecoData
load SigA SigA 

% all output directories to export figures and files
out_reg_dir = 'Output/macro-announcements/regressions/';

% some global variables
eventList = ecoMap.keys;


%% Macro Regressions on Implied Volatility y = β + β*S + ϵ

% compute pivot table with Surprise Z-score
beta1 = pivotTable(ecoData, 'SURPRISES', 'RELEASE_DATE', 'NAME');

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta1"), ...
    beta1.Properties.VariableNames(2:end));


for col = 2:length(beta1.Properties.VariableNames)
    
    % filter only rows with values > 0 (standard deviation positive)
    series = beta1{beta1{:, col} > 0, col};
    
    % condition periods based on uncertainity windows 
    idx1 = (beta1{:, col} > 0); idx2 = (beta1{:, col} <= 0);
    
    % remaping the values by indicator random variable for rate regime
    beta1(idx1, col) = {1}; beta1(idx2, col) = {0}; 
    
end

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(beta1, iv, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVol.csv'));

%% Macro Regressions on Implied Volatility y = β + β*S + β*U25 + β*U25*S + ϵ

% comptue the beta components for each event 
beta1 = pivotTable(ecoData, 'SURPRISES', 'RELEASE_DATE', 'NAME');
beta2 = pivotTable(ecoData, 'FORECAST_STANDARD_DEVIATION', 'RELEASE_DATE', 'NAME');

for col = 2:length(beta1.Properties.VariableNames)
    
    % filter only rows with values > 0 (standard deviation positive)
    series = beta2{beta2{:, col} > 0, col};
    
    % determine the uncertainity cut-off windows
    bound = prctile(series, 25); 
    
    % condition periods based on uncertainity windows 
    idx1 = (beta2{:, col} <= bound); idx2 = (beta2{:, col} > bound);
    
    % remaping the values by indicator random variable for rate regime
    beta2(idx1, col) = {1}; beta2(idx2, col) = {0}; 
    
end

beta3 = pivotTable(ecoData, 'FORECAST_STANDARD_DEVIATION', 'RELEASE_DATE', 'NAME');
beta3{:, 2:end} = beta1{:, 2:end} .* beta2{:, 2:end};

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta1"), ...
    beta1.Properties.VariableNames(2:end));
beta2.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta2"), ...
    beta2.Properties.VariableNames(2:end));
beta3.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta3"), ...
    beta3.Properties.VariableNames(2:end));
 
% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression([beta1, beta2(:, 2:end), beta3(:, 2:end)], iv, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVolUncertainty_25.csv'));

%% Macro Regressions on Implied Volatility y = β + β*S + β*U75 + β*U75*S + ϵ

% comptue the beta components for each event 
beta1 = pivotTable(ecoData, 'SURPRISES', 'RELEASE_DATE', 'NAME');
beta2 = pivotTable(ecoData, 'FORECAST_STANDARD_DEVIATION', 'RELEASE_DATE', 'NAME');

for col = 2:length(beta1.Properties.VariableNames)
    
    % filter only rows with values > 0 (standard deviation positive)
    series = beta2{beta2{:, col} > 0, col};
    
    % determine the uncertainity cut-off windows
    bound = prctile(series, 75); 
    
    % condition periods based on uncertainity windows 
    idx1 = (beta2{:, col} < bound); idx2 = (beta2{:, col} >= bound);
    
    % remaping the values by indicator random variable for rate regime
    beta2(idx1, col) = {0}; beta2(idx2, col) = {1}; 
    
end

beta3 = pivotTable(ecoData, 'FORECAST_STANDARD_DEVIATION', 'RELEASE_DATE', 'NAME');
beta3{:, 2:end} = beta1{:, 2:end} .* beta2{:, 2:end};

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta1"), ...
    beta1.Properties.VariableNames(2:end));
beta2.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta2"), ...
    beta2.Properties.VariableNames(2:end));
beta3.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a(1:15), " Beta3"), ...
    beta3.Properties.VariableNames(2:end));
 
% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression([beta1, beta2(:, 2:end), beta3(:, 2:end)], iv, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVolUncertainty_75.csv'));

fprintf('5. All regressions are completed.\n')
