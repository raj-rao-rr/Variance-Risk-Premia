% Reads in data files and stores these variables to a .mat file

clear;

load INIT root_dir

% creating certificate for web access 
o = weboptions('CertificateFilename',"");

%% Effective Federal Funds Rate, taken from FRED website

% sets current date time to retrieve current information
currentDate = string(datetime('today', 'Format','yyyy-MM-dd'));

url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DFF&scale=left&cosd=1954-07-01&coed=2020-12-22&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%207-Day&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=" + currentDate +  "&revision_date=" + currentDate + "&nd=1954-07-01";

% read web data from FRED and stores it in appropriate file 
fedfunds = webread(url, o);
fedfunds = rmmissing(fedfunds);

%% The U.S. Treasury Yield Curve: 1961 to the Present

url = 'https://www.federalreserve.gov/data/yield-curve-tables/feds200628.csv';

% read web data from Federal Reserve and stores it in appropriate file 
websave(strcat(root_dir, '/Input/yeildCurve.csv'), url, o);
yeildCurve = readtable('yeildCurve.csv');

% select only the 1y, 5y, 10y zero-coupon yeilds
yeildCurve = yeildCurve(:, ismember(yeildCurve.Properties.VariableNames, ...
    {'Date', 'SVENY01', 'SVENY05', 'SVENY10'}));

% remove NaNs and missing rows from the dataset
yeildCurve = rmmissing(yeildCurve);
yeildCurve = yeildCurve(~ismember(yeildCurve.SVENY10, 'NA'), :);

% convert 10y zero-coupon yeild from string to double precsion num
yeildCurve.SVENY10 = str2double(yeildCurve.SVENY10);

%% Swap and Implied Volatility Data, taken from Bloomberg

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
swapNames = swapData(:, 2:end).Properties.VariableNames;   

%% Economic Annoucements, tkaen from Bloomberg

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

% re-map all values of NaN or inf, as a result of ZeroDivsionError
rm = ecoData(isinf(ecoData.SurpriseZscore)| isnan(ecoData.SurpriseZscore), :);
ecoData(isinf(ecoData.SurpriseZscore) | isnan(ecoData.SurpriseZscore), ...
    'SurpriseZscore') = array2table(zeros(size(rm, 1), 1)); 

keys = [{'NFP TCH Index'}, {'INJCJC Index'}, {'FDTR Index'}, ...
    {'GDP CQOQ Index'}, {'CPI CHNG Index'}, {'NAPMPMI Index'}, ...
    {'CONSSENT Index'}, {'USURTOT Index'}, {'RSTAMOM Index'}, ...
    {'PCE CMOM Index'}];

econVars = {'Change in Non-farm Payrolls', 'Initial Jobless Claims', ...
    'FOMC Rate Decision', 'GDP Annualized QoQ', 'CPI MoM', ...
    'ISM Manufacturing', 'University of Michigan Sentiment', ...
    'Unemployment Rate', 'Retail Sales Advance MoM', ...
    'PCE Core Deflator MoM'};

% creates a map (hashtable/dictionary) for corresponding economic annc.
ecoMap = containers.Map(keys,econVars);

ecoData = ecoData(ismember(ecoData{:, 'Ticker'}, keys), :);

%% Determing Interest Rate Regimes

lowIR = fedfunds(fedfunds{:, 2} < 2,:);      % fed funds rate < 2%
highIR = fedfunds(fedfunds{:, 2} >= 2,:);    % fed funds rate >= 2%

%% Constricting the time horizon (comment out if ununsed)

dateStop = datetime('2020-03-01', 'InputFormat', 'yyyy-MM-dd');

swapData        = swapData(swapData{:,1} < dateStop, :);
treasuryData    = treasuryData(treasuryData{:,1} < dateStop, :);
normalVol       = normalVol(normalVol{:,1} < dateStop, :);
blackVol        = blackVol(blackVol{:,1} < dateStop, :);
ecoData         = ecoData(ecoData{:,1} < dateStop, :);
fedfunds        = fedfunds(fedfunds{:,1} < dateStop, :);
yeildCurve      = yeildCurve(yeildCurve{:,1} < dateStop, :);

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'blackVol',  'normalVol' , 'treasuryData', 'yeildCurve', ...
    'swapData', 'vixData', 'swapNames', 'ecoMap', 'ecoData', 'keys', ...
    'econVars', 'fedfunds', 'lowIR', 'highIR')

fprintf('Data has been downloaded.\n'); 
