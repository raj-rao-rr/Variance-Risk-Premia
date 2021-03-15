% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and volatility data
load DATA yeildCurve ecoMap blackVol lowIR highIR fedfunds swap3m10y ...
    swap3m2y swap3m5y
load FILTER cleanEco ecoSTD25 ecoSTD75
load SigA SigA 

% loading in VRP measures
load VRP vrp

% all output directories to export figures and files
out_reg_dir = 'Output/macro-announcements/regressions/';

% some global variables
eventList = ecoMap.keys;

%% Macro Regressions on Implied Volatility y = β + β*Z + ϵ

% compute pivot table with Surprise Z-score
beta1 = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta1"), ...
    beta1.Properties.VariableNames(2:end));

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(beta1, blackVol, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVol.csv'));

%% Macro Regressions on Implied Volatility y = β + β*Z + β*σ + + β*σ*Z + ϵ

% compute pivot table with Surprise Z-score and restricted events
sig_events = {'Change in Nonfarm Payrolls', 'ISM Manufacturing', ...
    'PPI Ex Food and Energy MoM', 'Retail Sales Advance MoM'};
filterEco = cleanEco(ismember(cleanEco.Event, sig_events), :);

% comptue the beta components for each event 
beta1 = pivotTable(filterEco, 'SurpriseZscore', 'DateTime', 'Event');
beta2 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');
beta3 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');
beta3{:, 2:end} = beta1{:, 2:end} .* beta2{:, 2:end};

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta1"), ...
    beta1.Properties.VariableNames(2:end));
beta2.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta2"), ...
    beta1.Properties.VariableNames(2:end));
beta3.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta3"), ...
    beta1.Properties.VariableNames(2:end));
 
% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression([beta1, beta2(:, 2:end), beta3(:, 2:end)], blackVol, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVolUncertainty_reduced.csv'));

%% Macro Regressions on Implied Volatility y = β + β*Z + β*U25 + + β*U25*Z + ϵ

% compute pivot table with Surprise Z-score and restricted events
sig_events = {'Change in Nonfarm Payrolls', 'ISM Manufacturing', ...
    'PPI Ex Food and Energy MoM', 'Retail Sales Advance MoM'};
filterEco = cleanEco(ismember(cleanEco.Event, sig_events), :);

% comptue the beta components for each event 
beta1 = pivotTable(filterEco, 'SurpriseZscore', 'DateTime', 'Event');
beta2 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');

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

beta3 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');
beta3{:, 2:end} = beta1{:, 2:end} .* beta2{:, 2:end};

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta1"), ...
    beta1.Properties.VariableNames(2:end));
beta2.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta2"), ...
    beta1.Properties.VariableNames(2:end));
beta3.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta3"), ...
    beta1.Properties.VariableNames(2:end));
 
% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression([beta1, beta2(:, 2:end), beta3(:, 2:end)], blackVol, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVolUncertainty_25.csv'));

%% Macro Regressions on Implied Volatility y = β + β*Z + β*U75 + + β*U75*Z + ϵ

% compute pivot table with Surprise Z-score and restricted events
sig_events = {'Change in Nonfarm Payrolls', 'ISM Manufacturing', ...
    'PPI Ex Food and Energy MoM', 'Retail Sales Advance MoM'};
filterEco = cleanEco(ismember(cleanEco.Event, sig_events), :);

% comptue the beta components for each event 
beta1 = pivotTable(filterEco, 'SurpriseZscore', 'DateTime', 'Event');
beta2 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');

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

beta3 = pivotTable(filterEco, 'StdDev', 'DateTime', 'Event');
beta3{:, 2:end} = beta1{:, 2:end} .* beta2{:, 2:end};

% rename the table names by beta coefficient intuition 
beta1.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta1"), ...
    beta1.Properties.VariableNames(2:end));
beta2.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta2"), ...
    beta1.Properties.VariableNames(2:end));
beta3.Properties.VariableNames(2:end) = cellfun(@(a) strcat(a, " Beta3"), ...
    beta1.Properties.VariableNames(2:end));
 
% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression([beta1, beta2(:, 2:end), beta3(:, 2:end)], blackVol, 'diff');

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressImpVolUncertainty_75.csv'));

%%

fprintf('All regressions are completed.\n')
