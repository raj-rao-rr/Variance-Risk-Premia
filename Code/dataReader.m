% Reads in the provided data files from Input and stores these variables to a .mat file

clear;

load INIT root_dir

%% Swap and Implied Volatility Data

% read in data from .csv file as a table   
blackVol = readtable('swapBlackIV.csv', 'PreserveVariableNames', true);     % N by 13 matrix
normalVol = readtable('swapNormalIV.csv', 'PreserveVariableNames', true);   % N by 13 matrix

treasuryData = readtable('TreasuryRate','PreserveVariableNames', true);     % N by 2 matrix
swapData = readtable('swapRates.csv', 'PreserveVariableNames', true);       % N by 7 matrix
vixData = readtable('VIX.csv', 'PreserveVariableNames', true);              % N by 2 matrix

% remove all NaN rows from the tables
blackVol = rmmissing(blackVol);        
normalVol = rmmissing(normalVol);        
treasuryData = rmmissing(treasuryData); 
swapData = rmmissing(swapData);  

% swap maturities: 1y; 2y; 3y; 5y; 7y; 10y;
swapRates = swapData(:,2:end).Properties.VariableDescriptions;   

%% Economic Annoucements

% run advanced python reader script to clean economic variables
!/apps/Anaconda3-2019.03/bin/python -b '/home/rcerxr21/DesiWork/VRP_GIT/Code/advancedReader.py'

% manipulate economic data releases (Bloomberg - ECO)
ecoData = readtable('cleanECO.csv', 'PreserveVariableNames', true);         % N by 21 matrix

ecoData = ecoData(ecoData{:, 'BB_relevance_index'} ~= 0, :);
ecoData = ecoData(~isnat(ecoData{:, 'DateTime'}), :);
ecoData = ecoData(~isnan(ecoData{:, 'SurvM'}) & ...
    ~isnan(ecoData{:, 'StdDev'}) & ~isnan(ecoData{:, 'Actual'}), :);

% selecting essential columns from economic releases
ecoData = ecoData(:, [3, 4, 11, 6, 12, 7, 10, 18]);

% compute zScore value by (Actual - survey Average) / Standard Deviation
ecoData.Surprise = ecoData{:, 'Actual'} - ecoData{:, 'SurvM'}; 
ecoData.SurpriseZscore = (ecoData{:, 'Actual'} - ecoData{:, 'SurvM'}) ./ ...
    ecoData{:, 'StdDev'}; 

% Key economic figures to extract
% CPI ex. Food & Enrgy MoM, Unemployment Rate, PPI Ex Food and Enrgy MoM, 
% PCE Core Deflator MoM, GDP Annualized QoQ, Retail Sales ex. Auto, 
% Change in Non-farm payrolls, Empire Manufacturing Survey, Trade Balance, 
% FOMC Rate Decison 
keys = [{'CPUPXCHG Index'}, {'USURTOT Index'}, {'FDIDSGMO Index'}, ...
    {'PCE CMOM Index'}, {'GDP CQOQ Index'}, {'RSTAXAG% Index'}, ... 
    {'NFP TCH Index'}, {'EMPRGBCI Index'}, {'USTBTOT Index'}, ...
    {'FDTR Index'}];

ecoData = ecoData(ismember(ecoData{:, 'Ticker'}, keys), :);

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'blackVol',  'normalVol' , 'treasuryData', 'swapData', ...
     'vixData', 'swapRates', 'ecoData', 'keys')
 
fprintf('Data has been downloaded.\n'); 
