% Reducing economic calender data according to criteria 

clear; 

load INIT root_dir

% loading in economic and volatility data
load DATA keys 

% loading in economic and implied volatility data
load DATA ecoData blackVol


%% Reduced economic calender data by forecast uncertainity (percentile)

% store economic calender dates for high/low forecast uncertainity 
ecoSTD10 = table();
ecoSTD25 = table();
ecoSTD75 = table();
ecoSTD90 = table();

% itterate through each of the events provided
for event = keys

    % filter data by macro economic event
    filterData = ecoData(ismember(ecoData{:, 'Ticker'}, event), :);

    % compute the top and bottom decile/quartiles forecast STD
    pct10 = quantile(filterData.StdDev, .10);
    pct25 = quantile(filterData.StdDev, .25);
    pct75 = quantile(filterData.StdDev, .75);
    pct90 = quantile(filterData.StdDev, .90);

    % bucket out economic figures according to std value
    ecoBin1 = filterData((filterData.StdDev <= pct10), :);
    ecoBin2 = filterData((filterData.StdDev <= pct25), :);
    ecoBin3 = filterData((filterData.StdDev >= pct75), :);
    ecoBin4 = filterData((filterData.StdDev >= pct90), :);

    % concat vertically all economic annoucments matching criteria
    ecoSTD10 = [ecoSTD10; ecoBin1];
    ecoSTD25 = [ecoSTD25; ecoBin2];
    ecoSTD75 = [ecoSTD75; ecoBin3];
    ecoSTD90 = [ecoSTD90; ecoBin4];

end

%% Reduced implied volatility measures by PCA of term (2y, 5y, 10y)

twoYears = {'USSV0C2Curncy', 'USSV0F2Curncy', 'USSV012Curncy', ...
    'USSV022Curncy'};
fiveYears = {'USSV0C5Curncy', 'USSV0F5Curncy', 'USSV015Curncy', ...
    'USSV025Curncy'};
tenYears = {'USSV0C10Curncy', 'USSV0F10Curncy', 'USSV0110Curncy', ...
    'USSV0210Curncy'};
Date = blackVol{:, 1};

[~, Term2ySwap, ~, ~, ~] = pca(blackVol{:, twoYears}, 'NumComponents', 1);
[~, Term5ySwap, ~, ~, ~] = pca(blackVol{:, fiveYears}, 'NumComponents', 1);
[~, Term10ySwap, ~, ~, ~] = pca(blackVol{:, tenYears}, 'NumComponents', 1);

impvolTermReduced = table(Date, Term2ySwap, Term5ySwap, Term10ySwap);

%% Reduced implied volatility measures by PCA of tenor (3m, 6m, 12m, 24m)

threeMonths = {'USSV0C2Curncy', 'USSV0C5Curncy', 'USSV0C10Curncy'};  
sixMonths = {'USSV0F2Curncy', 'USSV0F5Curncy', 'USSV0F10Curncy'};  
twelveMonths = {'USSV012Curncy', 'USSV015Curncy', 'USSV0110Curncy'};
twofourMonths = {'USSV022Curncy', 'USSV025Curncy', 'USSV0210Curncy'};

Date = blackVol{:, 1};

[~, Tenor3mSwap, ~, ~, ~] = pca(blackVol{:, threeMonths}, 'NumComponents', 1);
[~, Tenor6mSwap, ~, ~, ~] = pca(blackVol{:, sixMonths}, 'NumComponents', 1);
[~, Tenor12mSwap, ~, ~, ~] = pca(blackVol{:, twelveMonths}, 'NumComponents', 1);
[~, Tenor24mSwap, ~, ~, ~] = pca(blackVol{:, twofourMonths}, 'NumComponents', 1);

impvolTenorReduced = table(Date, Tenor3mSwap, Tenor6mSwap, Tenor12mSwap, ...
    Tenor24mSwap);

%% save changes to modified economic calender releases

save('Temp/FILTER', 'ecoSTD10', 'ecoSTD25', 'ecoSTD75', 'ecoSTD90', ...
    'impvolTermReduced', 'impvolTenorReduced')

fprintf('Data has been modifed and reduced.\n'); 
