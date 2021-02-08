% Reads in data files and stores these variables to a .mat file

clear;

load INIT root_dir

% creating certificate for web access 
o = weboptions('CertificateFilename',"");

% sets current date time to retrieve current information
currentDate = string(datetime('today', 'Format','yyyy-MM-dd'));


%% Effective Federal Funds Rate, taken from FRED website

url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DFF&scale=left&cosd=1954-07-01&coed=2020-12-22&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%207-Day&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=" + currentDate +  "&revision_date=" + currentDate + "&nd=1954-07-01";

% read web data from FRED and stores it in appropriate file 
fedfunds = webread(url, o);
fedfunds = rmmissing(fedfunds);

% extend moving averages for Fed Funds Rate
fedfunds.MA30 = movmean(fedfunds{:, 2}, [30, 0], 'endpoints', 'fill');
fedfunds.MA500 = movmean(fedfunds{:, 2}, [500, 0], 'endpoints', 'fill');

% difference between 30d and 500d moving average
fedfunds.Diff = fedfunds.MA30 - fedfunds.MA500;

%% NBER based Recession Indicators for the United States (USRECD)

url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=off&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=USRECD&scale=left&cosd=1854-12-01&coed=" + currentDate + "&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%207-Day&fam=avg&fgst=lin&fgsnd=" + currentDate + "&line_index=1&transformation=lin&vintage_date=" + currentDate + "&revision_date=" + currentDate + "&nd=1854-12-01";

% read web data from FRED and stores it in appropriate file 
recessions = webread(url, o);
recessions = rmmissing(recessions);

recessions = recessions(recessions{:, 2} == 1, :);

%% CBOE Volatility Index: VIX 

url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=VIXCLS&scale=left&cosd=1990-01-02&coed=" + currentDate + "&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%20Close&fam=avg&fgst=lin&fgsnd=" + currentDate + "&line_index=1&transformation=lin&vintage_date=" + currentDate + "&revision_date=" + currentDate + "&nd=1990-01-02";

% read web data from FRED and stores it in appropriate file 
vix = webread(url, o);
vix = rmmissing(vix);

%% S&P 500, taken from Yahoo Finance (could also employ Bloomberg)

% read S&P 500 data from Yahoo Finance 
sp500 = readtable('^GSPC.csv', 'PreserveVariableNames', true);
sp500 = rmmissing(sp500);

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

% orient the columns of black-implied and normal-implied volatility
blackVol = blackVol(:, {'Date', 'USSV0C2Curncy', 'USSV0F2Curncy', 'USSV012Curncy', ...
    'USSV022Curncy', 'USSV0C5Curncy', 'USSV0F5Curncy', 'USSV015Curncy', ...
    'USSV025Curncy', 'USSV0C10Curncy', 'USSV0F10Curncy', 'USSV0110Curncy', ...
    'USSV0210Curncy'}); 

swapData = readtable('swapRates.csv', 'PreserveVariableNames', true);       % N by 7 matrix

% remove all NaN rows from the tables
blackVol        = rmmissing(blackVol);               
swapData        = rmmissing(swapData);  

% swap maturities: 1y; 2y; 3y; 5y; 7y; 10y;
swapNames = swapData(:, 2:end).Properties.VariableNames;   

%% Economic Annoucements, taken from Bloomberg

% run python script to clean economic variables with weird formats
% e.g. Non-farm payrolls 735k -> Non-farm payrools 735
!/apps/Anaconda3-2019.03/bin/python -b '/home/rcerxr21/DesiWork/VRP_GIT/Code/advancedReader.py'

% manipulate economic data releases (Bloomberg - ECO)
ecoData = readtable('cleanECO.csv', 'PreserveVariableNames', true);         % N by 21 matrix

% filter out significant economic variables according to Domenico G. paper
% macroReleases = {'Retail Sales Advance MoM', 'Business Inventories', ...
%     'Capacity Utilization', 'Change in Nonfarm Payrolls', ...
%     'Conf. Board Consumer Confidence', 'Consumer Credit', ...
%     'CPI MoM', 'CPI Ex Food and Energy MoM', 'Wards Domestic Vehicle Sales', ...
%     'Durable Goods Orders', 'Employment Cost Index', 'Factory Orders', ...
%     'Housing Starts', 'Import Price Index MoM', ...
%     'Industrial Production MoM', 'Initial Jobless Claims', ...
%     'ISM Manufacturing', 'ISM Non-Manufacturing', 'Leading Index', ...
%     'FOMC Rate Decision (Upper Bound)', 'FOMC Rate Decision (Lower Bound)', ...
%     'New Home Sales', 'Personal Income', 'Personal Spending', ...
%     'Philadelphia Fed Business Outlook', 'PPI Ex Food and Energy MoM', ...
%     'PPI MoM', 'Retail Sales Less Autos', 'Trade Balance', ...
%     'Unemployment Rate', 'Wholesale Inventories MoM', ...
%     'GDP Annualized QoQ A', 'GDP Annualized QoQ S', 'GDP Annualized QoQ T', ...
%     'GDP Price Index A', 'GDP Price Index S', 'GDP Price Index T', ...
%     'Nonfarm Productivity F', 'Nonfarm Productivity P',...
%     'Unit Labor Costs F', 'Unit Labor Costs P', 'U. of Mich. Sentiment F', ...
%     'U. of Mich. Sentiment P'};

macroReleases = {'Retail Sales Advance MoM', 'Change in Nonfarm Payrolls', ...
    'Conf. Board Consumer Confidence', 'CPI Ex Food and Energy MoM', ...
    'Durable Goods Orders', 'Initial Jobless Claims', 'ISM Manufacturing', ...
    'ISM Non-Manufacturing', 'GDP Annualized QoQ A', ...
    'FOMC Rate Decision (Upper Bound)', ...
    'Philadelphia Fed Business Outlook', 'PPI Ex Food and Energy MoM', ...
    'U. of Mich. Sentiment P'};

ecoData = ecoData(ismember(ecoData.Event, macroReleases), :);

% remove insignificant events and non-times
ecoData = ecoData(~isnat(ecoData{:, 'DateTime'}), :);

% only select event dates with a median, actual, and std value  
ecoData = ecoData(~isnan(ecoData.SurvM) & ~isnan(ecoData.Actual) & ...
    ~isnan(ecoData.StdDev), :);

% selecting essential columns from economic releases
ecoData = ecoData(:, {'DateTime', 'Event', 'Ticker', 'Period', ...
    'SurvM', 'Actual', 'Prior', 'BB_relevance_index', 'StdDev', 'Freq'});

% re-map all StdDev values from 0 to a very small number e.g. 0.0001
zeroTarget = ecoData(ecoData.StdDev == 0, :);
reMap = zeros(size(zeroTarget, 1), 1);
ecoData(ecoData.StdDev == 0, 'StdDev') = array2table(reMap + 0.0001);

% compute zScore value by (Actual - survey Average) / Standard Deviation
ecoData.Surprise = ecoData.Actual - ecoData.SurvM; 
ecoData.SurpriseZscore = ecoData.Surprise ./ ecoData.StdDev; 

% creates a map (hashtable/dictionary) for corresponding economic annc.
ecoMap = containers.Map(ecoData{:, 2}, ecoData{:, 3});

%% Determing Interest Rate and Volatility Regimes

lowIR = fedfunds(fedfunds{:, 2} < 2,:);      % fed funds rate < 2%
highIR = fedfunds(fedfunds{:, 2} >= 2,:);    % fed funds rate >= 2%

lowVIX = vix(vix{:, 2} < 20,:);              % VIX < 20%
highVIX = vix(vix{:, 2} >= 20,:);            % VIX >= 20%

%% Constricting the time horizon (comment out if ununsed)

dateStop = datetime('2020-03-01', 'InputFormat', 'yyyy-MM-dd');

swapData        = swapData(swapData{:,1} < dateStop, :);
blackVol        = blackVol(blackVol{:,1} < dateStop, :);
ecoData         = ecoData(ecoData{:,1} < dateStop, :);
fedfunds        = fedfunds(fedfunds{:,1} < dateStop, :);
yeildCurve      = yeildCurve(yeildCurve{:,1} < dateStop, :);
recessions      = recessions(recessions{:, 1} < dateStop, :);
vix             = vix(vix{:, 1} < dateStop, :);
sp500           = sp500(sp500{:, 1} < dateStop, :);

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'blackVol', 'yeildCurve', 'swapData', 'swapNames', ...
    'ecoMap', 'ecoData', 'sp500', 'fedfunds', 'lowIR', 'highIR', ...
    'recessions', 'vix', 'lowVIX', 'highVIX')

fprintf('Data has been downloaded.\n'); 
