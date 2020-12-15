% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and implied volatility data
load DATA ecoMap ecoData keys blackVol econVars lowIR highIR

load SigA SigA 

% loading in VRP measures
load VRP vrp


%% Initialization of variables and directories

% check to see if the following directories exists, if not create them
if ~exist('Output/MacroRegressions/', 'dir')
    mkdir Output/MacroRegressions/                                         
end

if ~exist('Output/MacroRegressions/RegressTermStructure/', 'dir')
    mkdir Output/MacroRegressions/RegressTermStructure/  
    
    % create directory for term structure graphs for full series
    mkdir Output/MacroRegressions/RegressTermStructure/full/
    
    mkdir Output/MacroRegressions/RegressTermStructure/full/vrp/ 
    mkdir Output/MacroRegressions/RegressTermStructure/full/iv/
    mkdir Output/MacroRegressions/RegressTermStructure/full/rv/
    
    % create directory for term structure graphs for partial series
    mkdir Output/MacroRegressions/RegressTermStructure/partial/
    
    mkdir Output/MacroRegressions/RegressTermStructure/partial/vrp/ 
    mkdir Output/MacroRegressions/RegressTermStructure/partial/vrp/high/
    mkdir Output/MacroRegressions/RegressTermStructure/partial/vrp/low/
    
    mkdir Output/MacroRegressions/RegressTermStructure/partial/iv/
    mkdir Output/MacroRegressions/RegressTermStructure/partial/iv/high/
    mkdir Output/MacroRegressions/RegressTermStructure/partial/iv/low/
    
    mkdir Output/MacroRegressions/RegressTermStructure/partial/rv/
    mkdir Output/MacroRegressions/RegressTermStructure/partial/rv/high/
    mkdir Output/MacroRegressions/RegressTermStructure/partial/rv/low/
end

if ~exist('Output/MacroRegressions/StdBuckets/', 'dir')
    mkdir Output/MacroRegressions/StdBuckets/  
    
    % create directory to store standard deviation buckets 
    mkdir Output/MacroRegressions/StdBuckets/vrp/ 
    mkdir Output/MacroRegressions/StdBuckets/iv/
    mkdir Output/MacroRegressions/StdBuckets/rv/ 
end

if ~exist('Output/MacroRegressions/TermStructure/', 'dir')
    mkdir Output/MacroRegressions/TermStructure/  
    
    % create directory to store standard deviation buckets 
    mkdir Output/MacroRegressions/TermStructure/vrp/ 
    mkdir Output/MacroRegressions/TermStructure/iv/
end

addpath([root_dir filesep 'Output' filesep 'MacroRegressions'])             

%% interest rate regimes according to fed funds rate

irEnv = {lowIR, highIR};
rateNames = {'Low Interest', 'High Interest'};
regimes = {'low', 'high'}; 
volData = {vrp, blackVol, SigA};
volFolder = {'vrp', 'iv', 'rv'};

%% Regression on Macro surprises over full economic horizon 

outDirectory = 'Output/MacroRegressions/RegressTermStructure/full';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
       
    % perform regression on bucket economic releases
    concatTB = regression(ecoData, volData{data}, 'Surprise', ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs.csv');
    writetable(concatTB, name);

end

fprintf('Regression .csv were created over the full span.\n');

%% Tenor Structure for Events (using VRP)

% load in data from VRP regressed values 
vrpRegress = readtable(strcat(outDirectory, '/vrp/regressCoefs.csv'));
ivRegress = readtable(strcat(outDirectory, '/iv/regressCoefs.csv'));
rvRegress = readtable(strcat(outDirectory, '/rv/regressCoefs.csv'));

% construct the term structure graphs of regression coeficients
termStructure(vrpRegress, "RegressTermStructure/full/vrp", keys, ...
    econVars, 'VRP Regress on Economic Surprises (full sample)');
termStructure(ivRegress, "RegressTermStructure/full/iv",  keys, ....
    econVars, 'Implied Vol Regress on Economic Surprises (full sample)');
termStructure(rvRegress, "RegressTermStructure/full/rv",  keys, ...
    econVars, 'Realized Vol Regress on Economic Surprises (full sample)');

fprintf('Term structure graphs were created.\n');

%% Regression on Macro surprises over partial economic horizons

outDirectory = 'Output/MacroRegressions/RegressTermStructure/partial';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
    
    % iterate through each interest rate regime {'low', 'high'}
    for index = 1:2
        
        % selects the interest rate environment 
        df = irEnv{:, index};

        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        % perform regression on bucket economic releases
        concatTB = regression(filterEco, volData{data}, 'StdDev', ecoMap);
        name = strcat(outDirectory, '/', volFolder{data}, '/', ...
            regimes{index}, '/regressCoefs.csv');
        writetable(concatTB, name);
    end
    
end

fprintf('Regression .csv files for partial economic horizons complete.\n');

%% Tenor Structure for Events (using VRP)

% load in data from VRP regressed values 
vrpLowRegress = readtable(strcat(outDirectory, ...
    '/vrp/low/regressCoefs.csv'));
ivLowRegress = readtable(strcat(outDirectory, ...
    '/iv/low/regressCoefs.csv'));
rvLowRegress = readtable(strcat(outDirectory, ...
    '/rv/low/regressCoefs.csv'));

vrpHighRegress = readtable(strcat(outDirectory, ...
    '/vrp/high/regressCoefs.csv'));
ivHighRegress = readtable(strcat(outDirectory, ...
    '/iv/high/regressCoefs.csv'));
rvHighRegress = readtable(strcat(outDirectory, ...
    '/rv/high/regressCoefs.csv'));

% construct the term structure graphs of regression coeficients
termStructure(vrpLowRegress, "RegressTermStructure/partial/vrp/low", ...
    keys, econVars, ...
    'VRP Regress on Economic Surprises (low interest regime)');
termStructure(ivLowRegress, "RegressTermStructure/partial/iv/low", ...
    keys, econVars, ...
    'Implied Vol Regress on Economic Surprises (low interest regime)');
termStructure(rvLowRegress, "RegressTermStructure/partial/rv/low", ...
    keys, econVars, ...
    'Realized Vol Regress on Economic Surprises (low interest regime)');

termStructure(vrpHighRegress, "RegressTermStructure/partial/vrp/high", ...
    keys, econVars, ...
    'VRP Regress on Economic Surprises (high interest regime)');
termStructure(ivHighRegress, "RegressTermStructure/partial/iv/high", ...
    keys, econVars, ...
    'Implied Vol Regress on Economic Surprises (high interest regime)');
termStructure(rvHighRegress, "RegressTermStructure/partial/rv/high", ...
    keys, econVars, ...
    'Realized Vol Regress on Economic Surprises (high interest regime)')

fprintf('Term structure graphs for partial economic horizons created.\n');

%% Regression on Macro surprises over standard deviation buckets 

outDirectory = 'Output/MacroRegressions/RegressTermStructure/full';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 2:2
    
    % store economic calender dates for high/low forecast uncertainity 
    small_unc = table();
    large_unc = table();
    
    for i = keys(2)

        % filter data by macro economic event
        filterData = ecoData(ismember(ecoData{:, 'Ticker'}, i), :);
        
        % compute the top and bottom decile/quartiles forecast STD
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);

        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin2 = filterData((filterData.StdDev >= top25), :);

        % concat vertically all economic annoucments matching criteria
        small_unc = [small_unc; ecoBin1];
        large_unc = [large_unc; ecoBin2];
    end
  
    % perform regression on bucket economic releases
    concatTB = regression(small_unc, volData{data}, 'SurpriseZscore', ...
        ecoMap);
    disp(concatTB)
%     name = strcat(outDirectory, '/', volFolder{data}, '/', ...
%         '/regressCoefs25bucket.csv');
%     writetable(concatTB, name);
    
%     concatTB = regression(large_unc, volData{data}, 'SurpriseZscore', ...
%         ecoMap);
%     name = strcat(outDirectory, '/', volFolder{data}, '/', ...
%         '/regressCoefs75bucket.csv');
%     writetable(concatTB, name);
   
end

fprintf('Regression .csv were created over the std span.\n');

%% Interest rate buckets, alongside economic forecast STD buckets (VRP)

for i = 1:10
    fig = figure('visible', 'off');                 
    set(gcf, 'Position', [100, 100, 1500, 600]);   
    
    for index = 1:2
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, vrp, 1);
        datesBin2 = matchingError(ecoBin2, vrp, 1);
        datesBin3 = matchingError(ecoBin3, vrp, 1);
        datesBin4 = matchingError(ecoBin4, vrp, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, vrp, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, vrp, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, vrp, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, vrp, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = {mean(diffBin1(:, :),'omitnan'), ...
            mean(diffBin2(:, :),'omitnan'), ...
            mean(diffBin3(:, :),'omitnan'), ...
            mean(diffBin4(:, :),'omitnan')};

        % computes the simple average acroos row (per each date) - returns
        % scaler representing average VRP change across time and security
        simpleAvg = [mean(y{1}); mean(y{2}); mean(y{3}); mean(y{4})];
        
        % plotting out the bucket changes by positive/negative leaning
        subplot(1, 2, index);
        bar(simpleAvg); title(strcat(rateNames(index), ...
            ' Rate Environment'));
        xticks([1, 2, 3, 4]); 
        xticklabels({'10th', '25th', '75th', '90th'});
        ylim([min(min(simpleAvg))-0.5, max(max(simpleAvg))+0.5])
        xlabel('Forecast Standard Deviation Percentile', 'FontSize', 8);
        lgd = legend({'VRP Change'}, 'Location', 'northeast'); 
        lgd.FontSize = 8;                                                       
    
    end
    
    subplot(1, 2, 1);
    ylabel(strcat("Average VRP Change for ", econVars(i)), 'FontSize', 8);
    
    % export the image to Interest Bucket for VRP measures
    name = strcat("Output/MacroRegressions/StdBuckets/vrp/", ...
        event, ".jpg");
    exportgraphics(fig, name);
    
end

fprintf('VRP reponse graphs were created for interest rate regimes.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'vrpInterestBuckets']) 

%% Interest rate buckets, alongside economic forecast STD buckets (IV)

for i = 1:1
    fig = figure('visible', 'on');                 
    set(gcf, 'Position', [100, 100, 1500, 600]);   
    
    for index = 1:2
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, blackVol, 1);
        datesBin2 = matchingError(ecoBin2, blackVol, 1);
        datesBin3 = matchingError(ecoBin3, blackVol, 1);
        datesBin4 = matchingError(ecoBin4, blackVol, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, blackVol, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, blackVol, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, blackVol, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, blackVol, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = {mean(diffBin1(:, :),'omitnan'), ...
            mean(diffBin2(:, :),'omitnan'), ...
            mean(diffBin3(:, :),'omitnan'), ...
            mean(diffBin4(:, :),'omitnan')};

        % computes the simple average acroos row (per each date) - returns
        % scaler representing average VRP change across time and security
        simpleAvg = [mean(y{1}); mean(y{2}); mean(y{3}); mean(y{4})];
        
        % plotting out the bucket changes by positive/negative leaning
        subplot(1, 2, index);
        bar(simpleAvg); title(strcat(rateNames(index), ...
            ' Rate Environment'));
        xticks([1, 2, 3, 4]); 
        xticklabels({'10th', '25th', '75th', '90th'});
        ylim([min(min(simpleAvg))-0.5, max(max(simpleAvg))+0.5])
        xlabel('Forecast Standard Deviation Bucket', 'FontSize', 8);
        lgd = legend({'Implied Vol Change'}, 'Location', 'northeast'); 
        lgd.FontSize = 8;                                                       
    
    end
    
    subplot(1, 2, 1);
    ylabel(strcat("Average Implied Volatility Change for ", ...
        econVars(i)), 'FontSize', 8);
    
    % export the image to Interest Bucket for VRP measures
    name = strcat("Output/MacroRegressions/StdBuckets/iv/", ...
        event, ".jpg");
    exportgraphics(fig, name);
    
end

fprintf('IV reponse graphs were created for interest rate regimes.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'ivInterestBuckets']) 

%% Interest rate buckets, alongside economic forecast STD buckets (RV)

for i = 1:10
    fig = figure('visible', 'off');                 
    set(gcf, 'Position', [100, 100, 1500, 600]);   
    
    for index = 1:2
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, SigA, 1);
        datesBin2 = matchingError(ecoBin2, SigA, 1);
        datesBin3 = matchingError(ecoBin3, SigA, 1);
        datesBin4 = matchingError(ecoBin4, SigA, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, SigA, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, SigA, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, SigA, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, SigA, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = {mean(diffBin1(:, :),'omitnan'), ...
            mean(diffBin2(:, :),'omitnan'), ...
            mean(diffBin3(:, :),'omitnan'), ...
            mean(diffBin4(:, :),'omitnan')};

        % computes the simple average acroos row (per each date) - returns
        % scaler representing average VRP change across time and security
        simpleAvg = [mean(y{1}); mean(y{2}); mean(y{3}); mean(y{4})];
        
        % plotting out the bucket changes by positive/negative leaning
        subplot(1, 2, index);
        bar(simpleAvg); title(strcat(rateNames(index), ...
            ' Rate Environment'));
        xticks([1, 2, 3, 4]); 
        xticklabels({'10th', '25th', '75th', '90th'});
        ylim([min(min(simpleAvg))-0.5, max(max(simpleAvg))+0.5])
        xlabel('Forecast Standard Deviation Bucket', 'FontSize', 8);
        lgd = legend({'Realized Vol Change'}, 'Location', 'best'); 
        lgd.FontSize = 8;                                                       
    
    end
    
    subplot(1, 2, 1);
    ylabel(strcat("Average Realized Volatility Change for ", ...
        econVars(i)), 'FontSize', 8);
    
    % export the image to Interest Bucket for VRP measures
    name = strcat("Output/MacroRegressions/StdBuckets/rv/", ...
        event, ".jpg");
    exportgraphics(fig, name);
    
end

fprintf('RV reponse graphs were created for interest rate regimes.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'rvInterestBuckets']) 

%% Timeseries of VRP changes by STD buckets 

fig = figure('visible', 'off');                 
set(gcf, 'Position', [100, 100, 1100, 600]);   

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',8)

% allocate memory for low and high interest rate regime 
vrpIR = zeros(10, 2);

% iterate through economic variables
for i = 1:10
    
    % iterate through interest rate regime
    for index = 1:2
        
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, vrp, 1);
        datesBin2 = matchingError(ecoBin2, vrp, 1);
        datesBin3 = matchingError(ecoBin3, vrp, 1);
        datesBin4 = matchingError(ecoBin4, vrp, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, vrp, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, vrp, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, vrp, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, vrp, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = [mean(mean(diffBin1(:, :), 'omitnan')), ...
            mean(mean(diffBin2(:, :), 'omitnan')), ...
            mean(mean(diffBin3(:, :), 'omitnan')), ...
            mean(mean(diffBin4(:, :), 'omitnan'))];

        % scaler representing average VRP change across time and bucket
        simpleAvg = mean(y, 'omitnan'); 
                                                             
        vrpIR(i, index) = simpleAvg;
        
    end
    
end

% compute confidence intervals for both low/high rate regimes (90%)
confidence = bootci(2000, {@mean, vrpIR}, 'alpha', 0.10);

hold on; 
% plottin the long run average and time series of VRP per rate regime 
h(1,1) = scatter((1:10)', vrpIR(:, 1), 'red', 'd', 'filled', ...
    'DisplayName', 'Low Rate Regime', 'MarkerEdgeColor', 'black');
h(2,1) = plot(zeros(10, 1)+mean(vrpIR(:, 1)), 'DisplayName', ...
    'Low Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'red');
h(3,1) = plot(zeros(10, 1)+confidence(1, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'red');

h(4,1) = scatter((1:10)', vrpIR(:, 2), 'blue', 's', 'filled', ...
    'DisplayName', 'High Rate Regime', 'MarkerEdgeColor', 'black');
h(5,1) = plot(zeros(10, 1)+mean(vrpIR(:, 2)), 'DisplayName', ...
    'High Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'blue');
h(6,1) = plot(zeros(10, 1)+confidence(1, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'blue');

h(7,1) = plot(zeros(10, 1)+confidence(2, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'red');
h(8,1) = plot(zeros(10, 1)+confidence(2, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'blue');

xticks(1:10); xticklabels(econVars); xtickangle(30);
title({'VRP Responsivness to Economic Annoucments', ...
    'Responses are taken at STD percentiles (0.10, 0.25, 0.75, 0.90)'});
ylabel("Average VRP Change by STD Bucket", 'FontSize', 8);
legend(h(1:6))

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/avgVRP.jpg");
exportgraphics(fig, name);

fprintf('VRP time series graphs were created.\n');


%% Timeseries of Implied Volatility changes by STD buckets 

fig = figure('visible', 'off');                 
set(gcf, 'Position', [100, 100, 1100, 600]);   

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',8)

% allocate memory for low and high interest rate regime 
ivIR = zeros(10, 2);

% iterate through economic variables
for i = 1:10
    
    % iterate through interest rate regime
    for index = 1:2
        
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  
        
        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, blackVol, 1);
        datesBin2 = matchingError(ecoBin2, blackVol, 1);
        datesBin3 = matchingError(ecoBin3, blackVol, 1);
        datesBin4 = matchingError(ecoBin4, blackVol, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, blackVol, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, blackVol, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, blackVol, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, blackVol, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = [mean(mean(diffBin1(:, :), 'omitnan')), ...
            mean(mean(diffBin2(:, :), 'omitnan')), ...
            mean(mean(diffBin3(:, :), 'omitnan')), ...
            mean(mean(diffBin4(:, :), 'omitnan'))];

        % scaler representing average VRP change across time and bucket
        simpleAvg = mean(y, 'omitnan'); 
                                                             
        ivIR(i, index) = simpleAvg;
        
    end
    
end

% compute confidence intervals for both low/high rate regimes (90%)
confidence = bootci(2000, {@mean, ivIR}, 'alpha', 0.10);

hold on; 
% plottin the long run average and time series of VRP per rate regime 
h(1,1) = scatter((1:10)', ivIR(:, 1), 'cyan', 'd', 'filled', ...
    'DisplayName', 'Low Rate Regime', 'MarkerEdgeColor', 'black');
h(2,1) = plot(zeros(10, 1)+mean(ivIR(:, 1)), 'DisplayName', ...
    'Low Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'cyan');
h(3,1) = plot(zeros(10, 1)+confidence(1, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'cyan');

h(4,1) = scatter((1:10)', ivIR(:, 2), 'magenta', 's', 'filled', ...
    'DisplayName', 'High Rate Regime', 'MarkerEdgeColor', 'black');
h(5,1) = plot(zeros(10, 1)+mean(ivIR(:, 2)), 'DisplayName', ...
    'High Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'magenta');
h(6,1) = plot(zeros(10, 1)+confidence(1, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'magenta');

h(7,1) = plot(zeros(10, 1)+confidence(2, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'cyan');
h(8,1) = plot(zeros(10, 1)+confidence(2, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'magenta');

xticks(1:10); xticklabels(econVars); xtickangle(30);
title({'Implied Volatility Responsivness to Economic Annoucments', ...
    'Responses are taken at STD percentiles (0.10, 0.25, 0.75, 0.90)'});
ylabel("Average Implied Volatility Change by STD Bucket", 'FontSize', 8);
legend(h(1:6))

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/avgIV.jpg");
exportgraphics(fig, name);

fprintf('IV time series graphs were created.\n');

%% Timeseries of Realized Volatility changes by STD buckets 

fig = figure('visible', 'off');                 
set(gcf, 'Position', [100, 100, 1200, 600]);   

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',8)

% allocate memory for low and high interest rate regime 
rvIR = zeros(10, 2);
stdErr = zeros(10, 2);

% iterate through economic variables
for i = 1:10
    
    % iterate through interest rate regime
    for index = 1:2
        
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            df{:, 'DateMod'}), :);
        
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, SigA, 1);
        datesBin2 = matchingError(ecoBin2, SigA, 1);
        datesBin3 = matchingError(ecoBin3, SigA, 1);
        datesBin4 = matchingError(ecoBin4, SigA, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, SigA, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, SigA, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, SigA, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, SigA, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = [mean(mean(diffBin1(:, :), 'omitnan')), ...
            mean(mean(diffBin2(:, :), 'omitnan')), ...
            mean(mean(diffBin3(:, :), 'omitnan')), ...
            mean(mean(diffBin4(:, :), 'omitnan'))];

        % scaler representing average VRP change across time and bucket
        simpleAvg = mean(y, 'omitnan');
        simpleSTD = std(std([diffBin1; diffBin2; diffBin3; diffBin4], ...
           'omitnan'));
                                                             
        rvIR(i, index) = simpleAvg;
        stdErr(i, index) = simpleSTD;
    end
    
end

% compute confidence intervals for both low/high rate regimes (90%)
confidence = bootci(2000, {@mean, rvIR}, 'alpha', 0.10);

hold on; 
% plottin the long run average and time series of VRP per rate regime 
h(1,1) = scatter((1:10)', rvIR(:, 1), 'blue', 'd', 'filled', ...
    'DisplayName', 'Low Rate Regime', 'MarkerEdgeColor', 'black');
h(2,1) = plot(zeros(10, 1)+mean(rvIR(:, 1)), 'DisplayName', ...
    'Low Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'blue');
h(3,1) = plot(zeros(10, 1)+confidence(1, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'blue');

h(4,1) = scatter((1:10)', rvIR(:, 2), 'green', 's', 'filled', ...
    'DisplayName', 'High Rate Regime', 'MarkerEdgeColor', 'black');
h(5,1) = plot(zeros(10, 1)+mean(rvIR(:, 2)), 'DisplayName', ...
    'High Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'green');
h(6,1) = plot(zeros(10, 1)+confidence(1, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'green');

h(7,1) = plot(zeros(10, 1)+confidence(2, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'blue');
h(8,1) = plot(zeros(10, 1)+confidence(2, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'green');

xticks(1:10); xticklabels(econVars); xtickangle(30);
title({'Realized Volatility Responsivness to Economic Annoucments', ...
    'Responses are taken at STD percentiles (0.10, 0.25, 0.75, 0.90)'});
ylabel("Average Implied Volatility Change by STD Bucket", 'FontSize', 8);
legend(h(1:6))

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/avgRV.jpg");
exportgraphics(fig, name);

fprintf('Realized Volatility time series graphs were created.\n');

%% Distribution of vol changes across standard deviation for forecast 

fig = figure('visible', 'on');  
set(gcf, 'Position', [100, 100, 1250, 600]);
rng('default')  % For reproducibility

event = 'NFP TCH Index';
filterData1 = small_unc(strcmp(small_unc.Ticker, event), :);
filterData2 = large_unc(strcmp(large_unc.Ticker, event), :);

% match target dates for each STD period 
targetDate1 = matchingError(filterData1, blackVol, 1);
targetDate2 = matchingError(filterData2, blackVol, 1);

% change in regressed values pre-post announcement 
[diff1, eco1] = differenceSplit(filterData1, blackVol, targetDate1);
[diff2, eco2] = differenceSplit(filterData2, blackVol, targetDate2);

% perform regression on Z-scores to determine efficacy
[bv1,~,R2v1,~,~,~,F1] = olsgmm(mean(diff1, 2), eco1.SurpriseZscore, 0, 1);
[bv2,~,R2v2,~,~,~,F2] = olsgmm(mean(diff2, 2), eco2.SurpriseZscore, 0, 1);

% compute a scatter histogram for the average change in vol measure
subplot(1, 2, 1); hold on; 
scatter(eco1.SurpriseZscore, mean(diff1, 2), 'MarkerFaceColor', 'blue', ...
    'MarkerEdgeColor', 'black', 'DisplayName', '25th Percentile'); 
plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv1, 'LineStyle', '--', ...
    'color', 'black', 'DisplayName', ...
    strcat("R^2 ", string(round(R2v1, 3)), ", Pvalue ", string(round(F1(3), 2))))
title('Non-farm Payrolls Response under low uncertainty', 'FontSize', 10);
legend('show')

subplot(1, 2, 2); hold on; 
scatter(eco2.SurpriseZscore, mean(diff2, 2), 'MarkerFaceColor', 'red', ...
    'MarkerEdgeColor', 'black', 'DisplayName', '75th Percentile')
plot(eco2.SurpriseZscore, eco2.SurpriseZscore*bv2, 'LineStyle', '--', ...
    'color', 'black', 'DisplayName', ...
    strcat("R^2 ", string(round(R2v2, 3)), ", Pvalue ", string(round(F2(3), 2))))
title('Non-farm Payrolls Response under high uncertainty', 'FontSize', 10);

xlabel(strcat("Economic Surprise Z-score"), 'fontsize', 9)
ylabel("Change in Implied Volatility", 'fontsize', 9)
legend('show')

% % export the image to Interest Bucket for VRP measures
% name = strcat("Output/MacroRegressions/scatterHist.jpg");
% exportgraphics(fig, name);

%% Partial least squares regression (PLSR)

fig = figure('visible', 'off');  
set(gcf, 'Position', [100, 100, 1250, 600]);
rng('default')  % For reproducibility

event = 'FDTR Index';
filterData = ecoData(strcmp(ecoData.Ticker, event), :);

% match target dates for each STD period 
targetDate = matchingError(filterData, vrp, 1);

% change in regressed values pre-post announcement 
[diff, eco] = differenceSplit(filterData, vrp, targetDate);

% select only essential measures that are of interest
X = eco(:, {'SurvM', 'Actual', 'StdDev', 'Surprise', 'SurpriseZscore'});
X = table2array(X);

% remove periods where elements are 'inf' or 'nan'
y = mean(diff(~any(isnan(X)|isinf(X),2)), 2);
X = X(~any(isnan(X)|isinf(X),2), :);

[n,p] = size(X);

% compute the partial least squares regression, with 5 principal comps.
[Xl,Yl,Xscores,Yscores,betaPLS,PLSPctVar] = plsregress(X,y,5);
yfitPLS = [ones(n,1) X] * betaPLS;      % PLS reg. fit

TSS = sum((y-mean(y)).^2);              % total sum of squares
RSS_PLS = sum((y-yfitPLS).^2);          % sum of squared residuals
rsquaredPLS = 1 - RSS_PLS/TSS;

subplot(1,2,1)
scatter(y, yfitPLS, 'Marker', 's', 'MarkerEdgeColor', 'black', ...
    'MarkerFaceColor', 'red', 'DisplayName', 'PLSR with 5 princicpal components');
xlabel('Observed Response');
ylabel('Fitted Response');
title(strcat("R-squared observed ", string(round(rsquaredPLS, 3))))
legend('show', 'location','NW');

subplot(1,2,2)
plot(1:5,100*cumsum(PLSPctVar(2,:)),'b-o');
xlabel('Number of Principal Components');
ylabel('Percent Variance Explained in Y');
legend('PLSR', 'location','SE');

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/PLSR.jpg");
exportgraphics(fig, name);

% -----------------------------------------------------------------------

fig = figure('visible', 'on');  
set(gcf, 'Position', [100, 100, 950, 600]);

hold on; 
scatter(X(:, 3), yfitPLS, 'Marker', 'o', 'MarkerEdgeColor', 'black', ...
    'MarkerFaceColor', 'yellow', 'DisplayName', 'PLSR Fit Points')
xlabel(strcat("Standard Deviation for ", event, " Forecast"), ...
    'fontsize', 9)
ylabel("Change in Variance Risk Premium", 'fontsize', 9)
xlim([-0.025, max(X(:, 3))+0.05])
legend show

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/PLSR_Scatter.jpg");
exportgraphics(fig, name);

% -----------------------------------------------------------------------

fig = figure('visible', 'off');  
set(gcf, 'Position', [100, 100, 950, 600]);

fullRegCoefs = fitlm(eco.StdDev, mean(diff, 2)).Coefficients;
reducedRegCoefs = fitlm(X(:, 3), yfitPLS).Coefficients;
regRange = 0:0.01:max(X(:, 3))+0.1;

hold on; 
scatter(X(:, 3), yfitPLS, 'Marker', 'o', 'MarkerEdgeColor', 'black', ...
    'MarkerFaceColor', 'yellow', 'DisplayName', 'PLSR Fit Points')
plot(regRange, reducedRegCoefs{2,1}*regRange+reducedRegCoefs{1, 1}, ...
    'LineStyle', '--', 'LineWidth', 2, 'color', 'red', 'DisplayName', ...
    'Regression on Fit Points')
plot(regRange, fullRegCoefs{2,1}*regRange+fullRegCoefs{1, 1}, ...
    'LineStyle', '--', 'LineWidth', 2, 'color', 'blue', 'DisplayName', ...
    'Regression on All Points')

scatter(eco.StdDev, mean(diff, 2), 'Marker', 'o', 'MarkerEdgeColor', ...
    'black', 'DisplayName', 'Observed')
xlabel(strcat("Standard Deviation for ", event, " Forecast"), ...
    'fontsize', 9)
ylabel("Change in Variance Risk Premium", 'fontsize', 9)
xlim([-0.025, max(X(:, 3))+0.05])
legend show

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/PLSR_Fit_Regress.jpg");
exportgraphics(fig, name);

%% Construct term strucutre variant for pre/post annoucement window (VRP)

% iterate through various volatility measures
for index = 1:2
    
    % volatility data being examined
    data = volData(index);
    data = data{:};
    volName = volFolder(index);
    
    for event = keys
        fig = figure('visible', 'off');  
        set(gcf, 'Position', [100, 100, 1250, 600]);

        name = event{:};
        eventName = ecoMap(name); period = 1;

        % filter economic dates according to interest rate regime 
        filterLowEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
            lowIR{:, 'DateMod'}), :);
        filterHighEco = ecoData(ismember(ecoData{:, 'DateMod'}, ...
           highIR{:, 'DateMod'}), :);

        % filter economic data according to appropriate event
        filterLowData=filterLowEco(strcmp(filterLowEco.Ticker,event), :);
        filterHighData=filterHighEco(strcmp(filterHighEco.Ticker,event),:);

        % match target dates according to the date prior examined
        targetLowDate = matchingError(filterLowData, data, period);
        targeHighDate = matchingError(filterHighData, data, period);

        % select dates of pre/post annoucment window for vol measures
        afterLowAnnouce = data(ismember(data{:, 1}, ...
            targetLowDate), :);
        beforeLowAnnouce = data(ismember(data{:, 1}, ...
            targetLowDate-period), :);

        afterHighAnnouce = data(ismember(data{:, 1}, ...
            targeHighDate), :);
        beforeHighAnnouce = data(ismember(data{:, 1}, ...
            targeHighDate-period), :);

        % reshape for easy plotting in environment
        afterLowValues = reshape(mean(afterLowAnnouce{:, 2:end}),4,3);
        beforeLowValues = reshape(mean(beforeLowAnnouce{:, 2:end}),4,3);

        afterHighValues = reshape(mean(afterHighAnnouce{:, 2:end}),4,3);
        beforeHighValues = reshape(mean(beforeHighAnnouce{:, 2:end}),4,3);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % low interest rate enviornment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(1,2,1); hold on;
        plot(afterLowValues(:, 1), 'LineStyle', '--', 'color', 'red', ...
            'Marker', 'd', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (post Ann.)');
        plot(beforeLowValues(:, 1), 'LineStyle', '-', 'color', 'red', ...
            'Marker', 's', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (pre Ann.)');

        plot(afterLowValues(:, 2), 'LineStyle', '--', 'color', 'blue', ...
            'Marker', 'd', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (post Ann.)');
        plot(beforeLowValues(:, 2), 'LineStyle', '-', 'color', 'blue', ...
            'Marker', 's', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (pre Ann.)');

        plot(afterLowValues(:, 3), 'LineStyle', '--', 'color', 'green', ...
            'Marker', 'd', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (post Ann.)');
        plot(beforeLowValues(:, 3), 'LineStyle', '-', 'color', 'green', ...
            'Marker', 's', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (pre Ann.)');

        xticks(1:4); xticklabels({'3m', '6m', '12m', '24m'});
        ylabel('Variance Risk Premium');
        title({'Low Interest Rate Regime', name})
        legend('show', 'Location', 'northwest', 'fontsize', 8);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % high interest rate enviornment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(1,2,2); hold on;

        plot(afterHighValues(:, 1), 'LineStyle', '--', 'color', 'red', ...
            'Marker', 'd', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (post Ann.)');
        plot(beforeHighValues(:, 1), 'LineStyle', '-', 'color', 'red', ...
            'Marker', 's', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (pre Ann.)');

        plot(afterHighValues(:, 2), 'LineStyle', '--', 'color', 'blue', ...
            'Marker', 'd', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (post Ann.)');
        plot(beforeHighValues(:, 2), 'LineStyle', '-', 'color', 'blue', ...
            'Marker', 's', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (pre Ann.)');

        plot(afterHighValues(:, 3), 'LineStyle', '--', 'color', 'green', ...
            'Marker', 'd', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (post Ann.)');
        plot(beforeHighValues(:, 3), 'LineStyle', '-', 'color', 'green', ...
            'Marker', 's', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (pre Ann.)');

        xticks(1:4); xticklabels({'3m', '6m', '12m', '24m'});
        title({'High Interest Rate Regime', name})

        % export the image to Interest Bucket for VRP measures
        filename = strcat("Output/MacroRegressions/TermStructure/", ...
            volName{:}, "/", event, '.jpg');
        
        exportgraphics(fig, filename);
        
    end
    
end

%% Function for Peforming Regressions on Macro Variables

function targetDates = matchingError(base, target, window)
%   Finds the intersection between both macro economic fields and the 
%   implied volatility/varaince risk premia levels provided
%   -------
%   :param: base   -> type table
%       Economic annoucments that track a particular event
%   :param: target -> type table
%       Target variable measure to track against economic event
%   :param: window -> type int
%       The number of periods to lookback, e.g. 1 = 1-day

   % annoucement data for economic measurements 
   annoucements = base{:, 1};

   % daily changes +/- day from release of annoucnemnt 
   % annoucement date EOD price - day prior EOD price
   post = target(ismember(target{:, 1}, annoucements), :);
   pre = target(ismember(target{:, 1}, annoucements-window), :);
   
   % find the intersection between date ranges
   targetDates = intersect(post{:, 1}, pre{:, 1}+window);
end


function [diff, eco] = differenceSplit(base, target, targetDate)
%   Computing the volatility difference between pre/post annoucements
%   as well as the filtered economic data 
%   -------
%   :param: base       -> type table
%       Economic annoucments that track a particular event
%   :param: target     -> type table
%       Target variable measure to track against economic event
%   :param: targetDate -> type datetime array
%       Intersecting dates for variables vectors 

    % change in regressed values pre-post announcement 
    post = target(ismember(target{:, 1}, targetDate), :);
    pre = target(ismember(target{:, 1}, targetDate-1), :);
    
    % compute the volatility measure difference
    diff = post{:, 2:end} - pre{:, 2:end};      

    % economic filtered data matching for y date time 
    eco = base(ismember(targetDate, base{:, 1}), :);
end


function tb = regression(X, y, col, map)
%   Peforms a regression on varaibles X, y. Where X is a table of economic  
%   data releases provided by Bloomberg and y is the measured target. 
%   These targets include our measure for Variance Risk premia, implied
%   volatility and realized volatiltity 
%   -------
%   :param: X   -> type table 
%       The economic surprises from Bloomberg to regress on 
%   :param: y   -> type table 
%       The volatility measures (include IV, RV and VRP)
%   :param: col -> type str 
%       The column from the economic surprises, to regress on 
%       e.g. "SurpriseZscore" 

    % all availabe macro events
    keys = unique(X{:, 'Ticker'})';
    
    [~, n] = size(y.Properties.VariableNames);
    [~, k] = size(keys);
    
    % initialize the columns that will be exported for regressed figures
    Coefs = zeros((n-1)*k, 1);
    StdErr = zeros((n-1)*k, 1);
    pValue = zeros((n-1)*k, 1);
    tStat = zeros((n-1)*k, 1);
    R2 = zeros((n-1)*k, 1);
    adjR2 = zeros((n-1)*k, 1);
    Event = cell((n-1)*k, 1);
    Security = cell((n-1)*k, 1);
    RegressVar = cell((n-1)*k, 1);
   
    % used to iterate through rows building table
    rows = 1;
    
    % iterate through each implied volatility measure (3 tenors, 4 terms) 
    for index = 1:n-1
        names = y.Properties.VariableNames{index+1};
        fprintf('Measure for %s swaption\n', names);

        % iterate through each of the key annoucement events
        for i = keys

               % filter out for particular economic data
               filterData = X(ismember(X{:, 'Ticker'}, i), :);
               
               % checking runtime of regressed values
               event = filterData{1, 'Event'}; 
               fprintf('\tRegressing on %s\n', event{:});
               
               % find the intersection between date ranges
               targetDates = matchingError(filterData, y, 1);
               
               % computes difference and economic surprise
               [diff, eco] = differenceSplit(filterData, y, targetDates);
               
               % perform linear regression with significance
               [est,sd_err,R2v,R2vadj,~,~,F] = olsgmm(diff(:, index), ...
                   eco{:, col}, 0, 1);
               
               % assigning the correct statistic to corresponding column 
               Coefs(rows, 1) = est;
               StdErr(rows, 1) = sd_err;
               pValue(rows, 1) = F(3);
               tStat(rows, 1) = est/sd_err;
               R2(rows, 1) = R2v;
               adjR2(rows, 1) = R2vadj;
               Event(rows, 1) = {map(i{:})};
               Security(rows, 1) = {names};
               RegressVar(rows, 1) = {col};
               
               % iteratively moving down the rows
               rows = rows + 1;
        end
        
    end
    
    tb = table(Coefs, StdErr, pValue, tStat, R2, adjR2, Event, ...
        Security, RegressVar);
end


function termStructure(tb, folder, keys, econVars, titleName)
%   Plots the term structure of p-Values for volatility measures regressed
%   on economic surprises for a given security tier
%   -------
%   :param: tb       -> type table
%   :param: fileName -> type str (double qoutes "..")
%   :param: keys     -> type cell array
%   :param: econVars -> type cell array
    
    % refer to corrext directory to store images
    directory = strcat('Output/MacroRegressions/', folder, '/');
    
    % determing the swaption risk buckets by tenor
    tier1 = {'USSV0C2Curncy', 'USSV0F2Curncy', 'USSV012Curncy', ...
        'USSV022Curncy'};
    tier2 = {'USSV0C5Curncy', 'USSV0F5Curncy', 'USSV015Curncy', ...
        'USSV025Curncy'};
    tier3 = {'USSV0C10Curncy', 'USSV0F10Curncy', 'USSV0110Curncy', ...
        'USSV0210Curncy'};
    
    % iterate through each event
    for i = 1:10
        % macro-variable event 
        event = keys(i);
        
        fig = figure('visible', 'off');
        set(gcf, 'Position', [100, 100, 900, 700]);
        
        % vrp regression filtered by security and event
        x2y = tb(ismember(tb{:, 'Security'}, tier1) ...
            & ismember(tb{:, 'Event'}, event), :);
        x5y = tb(ismember(tb{:, 'Security'}, tier2) ...
            & ismember(tb{:, 'Event'}, event), :);
        x10y = tb(ismember(tb{:, 'Security'}, tier3) ...
            & ismember(tb{:, 'Event'}, event), :);

        % construct the new modified subplots
        hold on;
        plot(x2y{:, 'Estimate'}, 'DisplayName', '2y Tenor', 'color', ...
            'red', 'Marker', 'o');
        plot(x5y{:, 'Estimate'}, 'DisplayName', '5y Tenor', 'color', ...
            'green', 'Marker', '+');
        plot(x10y{:, 'Estimate'}, 'DisplayName', '10y Tenor', 'color', ...
            'blue', 'Marker', 'x');
        xticks([1, 2, 3, 4]); xticklabels({'3m', '6m', '1y', '2y'});
        xlabel('Terms');
        ylabel(strcat("Regression Coefficient for ", econVars(i)), ...
            'FontSize', 8);
        title(titleName);

        % show the legend for the underlying series
        lgd = legend(); lgd.FontSize = 7;   
        hold off; 
        
        exportName = strcat(directory, event, '.jpg');
        exportgraphics(fig, exportName);
    end

end

