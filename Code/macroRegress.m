% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and volatility data
load DATA yeildCurve ecoMap ecoData blackVol lowIR highIR
load FILTER cleanEco ecoSTD25 ecoSTD75
load SigA SigA 

% loading in VRP measures
load VRP vrp

% all output directories to export figures and files
out_reg_dir = 'Output/macro-announcements/regressions/';

% some global variables
eventList = ecoMap.keys;


%% Macro Regressions on Treausry Yeilds 1y, 5y, 10y

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, yeildCurve, 1);

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefs.csv'));  

%% Macro Regressions on Treasury Yeilds 1y, 5y, 10y (low uncertainty)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefs25.csv'));      

%% Macro Regressions on Treasury Yeilds 1y, 5y, 10y (high uncertainty)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefs75.csv'));

%% Macro Regressions on Treasury Yeilds 1y, 5y, 10y (low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsLowRate.csv'));

%% Macro Regressions on Treasury Yeilds 1y, 5y, 10y (high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsHighRate.csv'));

%% Macro Regressions on Treasury Yeilds (low uncertainty and low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsLowRate25.csv'));

%% Macro Regressions on Treasury Yeilds (low uncertainty and high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsHighRate25.csv'));

%% Macro Regressions on Treasury Yeilds (high uncertainty and low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsLowRate75.csv'));

%% Macro Regressions on Treasury Yeilds (low uncertainty and high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, yeildCurve, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressYeildsCoefsHighRate75.csv'));

%% Macro Regressions on Implied Volatility

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, blackVol, 1);

% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefs.csv'));  

%% Macro Regressions on Implied Volatlity (low uncertainty)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefs25.csv'));      

%% Macro Regressions on Implied Volatility (high uncertainty)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(pvtb, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefs75.csv'));

%% Macro Regressions on Implied Volatility (low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsLowRate.csv'));

%% Macro Regressions on Implied Volatiltiy (high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsHighRate.csv'));

%% Macro Regressions on Implied Volatility (low uncertainty and low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsLowRate25.csv'));

%% Macro Regressions on Implied Volatility (low uncertainty and high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD25, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsHighRate25.csv'));

%% Macro Regressions on Implied Volatility (high uncertainty and low rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, lowIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsLowRate75.csv'));

%% Macro Regressions on Implied Volatility (low uncertainty and high rate env)

% compute pivot table with index of DateTime, columns Events
pvtb = pivotTable(ecoSTD75, 'SurpriseZscore', 'DateTime', 'Event');

filter = pvtb(ismember(pvtb{:, 1}, highIR{:, 1}), :); 

% compute regression tables with a 1-difference window for Yeild comp. 
tb1 = regression(filter, blackVol, 1);
    
% write regression coeffcients to table
writetable(tb1, strcat(out_reg_dir, 'regressIVCoefsHighRate75.csv'));

%%

fprintf('All regressions are completed.\n')