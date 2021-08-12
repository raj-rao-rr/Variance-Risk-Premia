% Reads in data files and stores these variables to a .mat file

clearvars -except root_dir;

% creating certificate for web access, extending timeout to 10 seconds 
o = weboptions('CertificateFilename',"", 'Timeout', 10);

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

%% Determing Interest Rate and Volatility Regimes

lowIR = fedfunds(fedfunds{:, 2} < 2,:);      % fed funds rate < 2%
highIR = fedfunds(fedfunds{:, 2} >= 2,:);    % fed funds rate >= 2%

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

%% S&P 500, taken from Bloomberg

% read S&P 500 data from Yahoo Finance 
sp500 = readtable('sp500.xlsx', 'PreserveVariableNames', true);
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

%% Swaps Data for 2y, 5y, 10y taken from Bloomberg

swapData = readtable('swapRates.xlsx', 'PreserveVariableNames', true);

% select each corresponding swap data term by column
swap_2y = swapData(:, 1:2); 
swap_2y.Properties.VariableNames = {'Dates', 'USSW2 CURNCY'};

swap_5y = swapData(:, 3:4); 
swap_5y.Properties.VariableNames = {'Dates', 'USSW5 CURNCY'};

swap_10y = swapData(:, 5:6);
swap_10y.Properties.VariableNames = {'Dates', 'USSW10 CURNCY'};

% concat all swap data points across date range
swaps = innerjoin(swap_2y, innerjoin(swap_5y, swap_10y)); 

% swap maturities: 1y; 2y; 3y; 5y; 7y; 10y;
swapNames = swapData(:, 2:end).Properties.VariableNames;   

%% Swaption Implied Volatility Data taken from Bloomberg

% read in data from .csv file as a table   
blackVol = readtable('swaptionIV.xlsx', 'PreserveVariableNames', true);    

% select each corresponding swaption IV term by column
iv3m2y = blackVol(:, 1:2); 
iv3m2y.Properties.VariableNames = {'Date', 'USSV0C2 CURNCY'};

iv3m5y = blackVol(:, 9:10); 
iv3m5y.Properties.VariableNames = {'Date', 'USSV0C5 CURNCY'};

iv3m10y = blackVol(:, 17:18);
iv3m10y.Properties.VariableNames = {'Date', 'USSV0C10 CURNCY'};

iv6m2y = blackVol(:, 3:4); 
iv6m2y.Properties.VariableNames = {'Date', 'USSV0F2 CURNCY'};

iv6m5y = blackVol(:, 11:12); 
iv6m5y.Properties.VariableNames = {'Date', 'USSV0F5 CURNCY'};

iv6m10y = blackVol(:, 19:20);
iv6m10y.Properties.VariableNames = {'Date', 'USSV0F10 CURNCY'};

iv12m2y = blackVol(:, 5:6); 
iv12m2y.Properties.VariableNames = {'Date', 'USSV012 CURNCY'};

iv12m5y = blackVol(:, 13:14); 
iv12m5y.Properties.VariableNames = {'Date', 'USSV015 CURNCY'};

iv12m10y = blackVol(:, 21:22);
iv12m10y.Properties.VariableNames = {'Date', 'USSV0110 CURNCY'};

iv24m2y = blackVol(:, 7:8); 
iv24m2y.Properties.VariableNames = {'Date', 'USSV022 CURNCY'};

iv24m5y = blackVol(:, 15:16); 
iv24m5y.Properties.VariableNames = {'Date', 'USSV025 CURNCY'};

iv24m10y = blackVol(:, 23:24);
iv24m10y.Properties.VariableNames = {'Date', 'USSV0210 CURNCY'};

% perform inner join on all seperate implied volatilites
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {iv24m10y, iv12m10y, iv6m10y, iv3m10y, iv24m5y, iv12m5y, ...
    iv6m5y, iv3m5y, iv24m2y, iv12m2y, iv6m2y, iv3m2y};
iv = col_order{1};

for k = 2:length(col_order)
   iv = innerjoin(col_order{k}, iv); 
end

%% Economic Annoucements, taken from Bloomberg

% manipulate economic data releases (Bloomberg - ECO)
ecoData = readtable('bloomberg_economic_releases.csv', 'PreserveVariableNames', ...
    true);         

macroReleases = {'Adjusted Retail Sales Less Autos SA Monthly % Change', ...
    'US Employees on Nonfarm Payrolls Total MoM Net Change SA', ...
    'Conference Board Consumer Confidence SA 1985=100', ...
    'US CPI Urban Consumers MoM SA', 'US Durable Goods New Orders Industries MoM SA', ...
    'US Initial Jobless Claims SA', 'ISM Manufacturing PMI SA', ...
    'ISM Manufacturing PMI SA', 'GDP US Chained 2012 Dollars QoQ SAAR', ...
    'Federal Funds Target Rate - Upper Bound', ...
    'Philadelphia Fed Business Outlook Survey Diffusion Index General Conditions', ...
    'US PPI Final Demand Less Foods and Energy MoM SA', ...
    'University of Michigan Consumer Sentiment Index'};

ecoData = ecoData(ismember(ecoData.NAME, macroReleases), :);

% remove insignificant events and non-times
ecoData = ecoData(~isnat(ecoData{:, 'RELEASE_DATE'}), :);

% only select event dates with a median, actual, and std value  
ecoData = ecoData(~isnan(ecoData.BN_SURVEY_MEDIAN) & ~isnan(ecoData.ACTUAL_RELEASE) & ...
    ~isnan(ecoData.FORECAST_STANDARD_DEVIATION), :);

% creates a map (hashtable/dictionary) for corresponding economic annc.
ecoMap = containers.Map(ecoData{:, 'NAME'}, ecoData{:, 'TICKER'});

%% Reduced economic calender data by forecast uncertainity (percentile)

% #####################################################################
% Note our uncertainity windows are subject to data sample 
% #####################################################################

% store economic calender dates for high/low forecast uncertainity 
ecoSTD25 = table();
ecoSTD75 = table();

% itterate through each of the events provided
for event = ecoMap.values

    % filter data by macro economic event
    filterData = ecoData(ismember(ecoData.NAME, event), :);

    % compute the top and bottom decile/quartiles forecast STD
    pct25 = quantile(filterData.FORECAST_STANDARD_DEVIATION, .25);
    pct75 = quantile(filterData.FORECAST_STANDARD_DEVIATION, .75);

    % bucket out economic figures according to std value
    ecoBin2 = filterData((filterData.FORECAST_STANDARD_DEVIATION <= pct25), :);
    ecoBin3 = filterData((filterData.FORECAST_STANDARD_DEVIATION >= pct75), :);

    % concat vertically all economic annoucments matching criteria
    ecoSTD25 = [ecoSTD25; ecoBin2];
    ecoSTD75 = [ecoSTD75; ecoBin3];

end

%% Constricting the time horizon (comment out if ununsed)

dateStop = datetime('2020-03-01', 'InputFormat', 'yyyy-MM-dd');

swapData        = swapData(swapData{:,1} < dateStop, :);
iv              = iv(iv{:,1} < dateStop, :);
ecoData         = ecoData(ecoData{:,1} < dateStop, :);
fedfunds        = fedfunds(fedfunds{:,1} < dateStop, :);
yeildCurve      = yeildCurve(yeildCurve{:,1} < dateStop, :);
recessions      = recessions(recessions{:, 1} < dateStop, :);
vix             = vix(vix{:, 1} < dateStop, :);
sp500           = sp500(sp500{:, 1} < dateStop, :);

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'iv', 'yeildCurve', 'lowIR', 'highIR', 'swaps', 'swapNames', ...
    'ecoMap', 'ecoData', 'sp500', 'fedfunds', 'recessions', 'vix', ...
    'ecoSTD25', 'ecoSTD75');

fprintf('Data has been downloaded.\n'); 
