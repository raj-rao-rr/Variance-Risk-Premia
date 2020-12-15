% Reads in the provided data files from Input and stores these variables to a .mat file

clear;

load INIT root_dir


%% FRED Data set pulls for Fed Funds Rates

fedfunds = readtable('FEDFUNDS.csv', 'PreserveVariableNames', true);            % N by 1 vector
fedfunds{:, 1} = datetime(fedfunds{:, 1},'InputFormat','yyyy-MMM-dd');
fedfunds = rmmissing(fedfunds);  

% create a date modification for month,year identifier
dateMod = string(month(fedfunds{:, 1})) + string(year(fedfunds{:, 1}));

fedfunds.DateMod = dateMod; 

%% Swap and Implied Volatility Data

% read in data from .csv file as a table   
blackVol = readtable('swapBlackIV.csv', 'PreserveVariableNames', true);     % N by 13 matrix
normalVol = readtable('swapNormalIV.csv', 'PreserveVariableNames', true);   % N by 13 matrix

treasuryData = readtable('TreasuryRate','PreserveVariableNames', true);     % N by 2 matrix
swapData = readtable('swapRates.csv', 'PreserveVariableNames', true);       % N by 7 matrix
vixData = readtable('VIX.csv', 'PreserveVariableNames', true);              % N by 2 matrix

% remove all NaN rows from the tables
blackVol        = rmmissing(blackVol);        
normalVol       = rmmissing(normalVol);        
treasuryData    = rmmissing(treasuryData); 
swapData        = rmmissing(swapData);  

% swap maturities: 1y; 2y; 3y; 5y; 7y; 10y;
swapRates = swapData(:,2:end).Properties.VariableNames;   

%% Economic Annoucements

% run python script to clean economic variables with weird formats
% e.g. Non-farm payrolls 735k -> Non-farm payrools 735
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

keys = [{'NFP TCH Index'}, {'INJCJC Index'}, {'FDTR Index'}, ...
    {'GDP CQOQ Index'}, {'CPI CHNG Index'}, {'NAPMPMI Index'}, ...
    {'CONSSENT Index'}, {'USURTOT Index'}, {'RSTAMOM Index'}, ...
    {'PCE CMOM Index'}];

econVars = {'Change in Non-farm payrolls', 'Initial Jobless Claims', ...
    'FOMC Rate Decison', 'GDP Annualized QoQ', 'CPI MoM', ...
    'ISM Manufacturing', 'U. of Mich. Sentiment', ...
    'Unemployment Rate', 'Retail Sales Advance MoM', ...
    'PCE Core Deflator MoM'};

% creates a map (hashtable/dictionary) for corresponding economic annc.
ecoMap = containers.Map(keys,econVars);

ecoData = ecoData(ismember(ecoData{:, 'Ticker'}, keys), :);

% create a date modification for month,year identifier
dateMod = string(month(ecoData{:, 1})) + string(year(ecoData{:, 1}));

ecoData.DateMod = dateMod; 

%% Determing Interest Rate Regimes

lowIR = fedfunds(fedfunds{:, 2} < 2,:);      % fed funds rate < 2%
highIR = fedfunds(fedfunds{:, 2} >= 2,:);    % fed funds rate >= 2%

%% Constricting the time horizon (comment out if ununsed)

dateStop = '3/1/2020';

swapData        = swapData(swapData{:,1} < dateStop, :);
treasuryData    = treasuryData(treasuryData{:,1} < dateStop, :);
normalVol       = normalVol(normalVol{:,1} < dateStop, :);
blackVol        = blackVol(blackVol{:,1} < dateStop, :);
ecoData         = ecoData(ecoData{:,1} < dateStop, :);
fedfunds        = fedfunds(fedfunds{:,1} < dateStop, :);

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'blackVol',  'normalVol' , 'treasuryData', ...
    'swapData', 'vixData', 'swapRates', 'ecoMap', 'ecoData', 'keys', ...
    'econVars', 'fedfunds', 'lowIR', 'highIR')

%% Save data files to sub-temp folder for use in python visualization 

writetable(blackVol, 'Temp/pythonTemps/structData/blackVol.csv');
writetable(normalVol, 'Temp/pythonTemps/structData/normalVol.csv');
writetable(treasuryData, 'Temp/pythonTemps/structData/treasuryData.csv');
writetable(swapData, 'Temp/pythonTemps/structData/swapData.csv');
writetable(vixData, 'Temp/pythonTemps/structData/vixData.csv');
writetable(ecoData, 'Temp/pythonTemps/structData/ecoData.csv');
writetable(fedfunds, 'Temp/pythonTemps/structData/fedfunds.csv');
writetable(lowIR, 'Temp/pythonTemps/structData/lowIR.csv');
writetable(highIR, 'Temp/pythonTemps/structData/highIR.csv')

fprintf('Data has been downloaded.\n'); 
