% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and implied volatility data
load DATA ecoData keys blackVol econVars lowIR highIR

load SigA SigA 

% loading in VRP measures
load VRP vrp


%% Initialization of variables and directories

% check to see if the following directories exists, if not create them
if ~exist('Output/MacroRegressions/', 'dir')
    mkdir Output/MacroRegressions/                                         
end

if ~exist('Output/MacroRegressions/vrpBuckets/', 'dir')
    mkdir Output/MacroRegressions/vrpBuckets/                                         
end

if ~exist('Output/MacroRegressions/vrpTermStruct/', 'dir')
    mkdir Output/MacroRegressions/vrpTermStruct/                                         
end

if ~exist('Output/MacroRegressions/ivTermStruct/', 'dir')
    mkdir Output/MacroRegressions/ivTermStruct/                                         
end

if ~exist('Output/MacroRegressions/rvTermStruct/', 'dir')
    mkdir Output/MacroRegressions/rvTermStruct/                                         
end

if ~exist('Output/MacroRegressions/vrpInterestBuckets/', 'dir')
    mkdir Output/MacroRegressions/vrpInterestBuckets/                                         
end

addpath([root_dir filesep 'Output' filesep 'MacroRegressions'])             

%% Regression on Macro surprises 

% regressing VRP measures against economic annoucnments surprise Z-scores 
concatTB = regression(ecoData, vrp, 'SurpriseZscore');

writetable(concatTB, 'Output/MacroRegressions/vrpRegress.csv');
disp('Macro regression .csv was created...');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'vrpTermStruct'])  

%% Regression against underlying black-scholes implied volatility 

% regressing IV measures against economic annoucnments surprise Z-scores 
concatTB = regression(ecoData, blackVol, 'SurpriseZscore');

writetable(concatTB, 'Output/MacroRegressions/ivRegress.csv');
fprintf('Implied volatility regression .csv was created.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'ivTermStruct']) 

%% Regression against underlying forecasted realized volatility 

% regressing RV measures against economic annoucnments surprise Z-scores 
concatTB = regression(ecoData, SigA, 'SurpriseZscore');

writetable(concatTB, 'Output/MacroRegressions/rvRegress.csv');
fprintf('GARCH forecasted volatility regression .csv was created.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'rvTermStruct']) 

%% Tenor Structure for Events (using VRP)

% load in data from VRP regressed values 
vrpRegress = readtable('vrpRegress.csv');
ivRegress = readtable('ivRegress.csv');
rvRegress = readtable('rvRegress.csv');

% construct the term structure graphs of regression coeficients
termStructure(vrpRegress, "vrpTermStruct", keys, econVars);
termStructure(ivRegress, "ivTermStruct",  keys, econVars);
termStructure(rvRegress, "rvTermStruct",  keys, econVars);

fprintf('Term structure graphs were created.\n');

%% Average change in VRP by STD buckets

for i = 1:10
    
    fig = figure('visible', 'off');                 
    set(gcf, 'Position', [100, 100, 800, 600]);   

    event = keys(i);
    
    % filter data by macro economic event
    filterData = ecoData(ismember(ecoData{:, 'Ticker'}, event), :);
    
    % compute the top quarter and bottom quarter forecast STD per event
    bottom25 = quantile(filterData.StdDev, .25);
    top25 = quantile(filterData.StdDev, .75);
    
    % bucket out economic figures according to std value
    lowECO = filterData((filterData.StdDev <= bottom25), :);
    midECO = filterData((top25 > filterData.StdDev) & ...
        (filterData.StdDev > bottom25), :);
    highECO = filterData((filterData.StdDev >= top25), :);
    
    % match target dates for each STD period 
    lowDates = matchingError(lowECO, vrp);
    midDates = matchingError(midECO, vrp);
    highDates = matchingError(highECO, vrp);
    
    % change in regressed values pre-post announcement 
    [lowDiff, eco1] = volDiff(lowECO, vrp, lowDates);
    [midDiff, eco2] = volDiff(midECO, vrp, midDates);
    [highDiff, eco3] = volDiff(highECO, vrp, highDates);
    
    % split economic figures into positive and negative surprises
    [lowPosECO, lowNegECO] = ecoSplits(eco1, 'Surprise');
    [midPosECO, midNegECO] = ecoSplits(eco2, 'Surprise');
    [highPosECO, highNegECO] = ecoSplits(eco3, 'Surprise');
    
    % split vrp figures according to positive and negative surprises 
    [lowPosDiff, lowNegDiff] = volSplits(lowDiff, lowPosECO, ...
        lowNegECO, lowDates);
    [midPosDiff, midNegDiff] = volSplits(midDiff, midPosECO, ...
        midNegECO, midDates);
    [highPosDiff, highNegDiff] = volSplits(highDiff, highPosECO, ...
        highNegECO, highDates);
    
    % building out the average difference cell per STD period
    % function computes the mean, column wise (per each security) 
    y = {mean(lowPosDiff(:, :)), mean(lowNegDiff(:, :)); ...
        mean(midPosDiff(:, :)), mean(midNegDiff(:, :)); ...
        mean(highPosDiff(:, :)), mean(highNegDiff(:, :))};
    
    % computes the simple average acroos row (per each date) - returns
    % scaler representing average VRP change across time and security
    simpleAvg = [mean(y{1, 1}), mean(y{1, 2}); mean(y{2, 1}), ...
        mean(y{2, 2}); mean(y{3, 1}), mean(y{3, 2})];
   
    % plotting out the bucket changes by positive/negative leaning
    bar(simpleAvg); title(strcat(econVars(i), ' Forecast'));
    xticks([1, 2, 3]); xticklabels({'Low Std', 'Mid Std', 'High Std'});
    ylim([min(min(simpleAvg))-0.5, max(max(simpleAvg))+0.5])
    ylabel('Average VRP Change over Period', 'FontSize', 8);
    xlabel('Forecast Standard Deviation', 'FontSize', 8);
    lgd = legend({'Positive Surprise', 'Negative Surprise'}, ...
        'Location', 'best'); 
    lgd.FontSize = 8;                                                       
    
    name = strcat("Output/MacroRegressions/vrpBuckets/", event, ".jpg");
    exportgraphics(fig, name);
end

fprintf('VRP bucket reponse graphs were created.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'vrpBuckets']) 

%% Interest rate buckets, alongside economic forecast STD buckets

% interest rate regimes according to fed funds rate
irEnv = {lowIR, highIR};
rateNames = {'Low Interest', 'High Interest'};

for i = 1:10
    fig = figure('visible', 'off');                 
    set(gcf, 'Position', [100, 100, 1100, 600]);   
    
    for index = 1:2
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter vrp according to interest rate regime 
        filterVRP = vrp(ismember(vrp{:, 1}, df{:, 1}), :);
       
        event = keys(i);    % economic event  

        % filter data by macro economic event
        filterData = ecoData(ismember(ecoData{:, 'Ticker'}, event), :);

        % compute the top quarter and bottom quarter forecast STD per event
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);

        % bucket out economic figures according to std value
        lowECO = filterData((filterData.StdDev <= bottom25), :);
        midECO = filterData((top25 > filterData.StdDev) & ...
            (filterData.StdDev > bottom25), :);
        highECO = filterData((filterData.StdDev >= top25), :);

        % match target dates for each STD period 
        lowDates = matchingError(lowECO, filterVRP);
        midDates = matchingError(midECO, filterVRP);
        highDates = matchingError(highECO, filterVRP);

        % change in regressed values pre-post announcement 
        [lowDiff, eco1] = volDiff(lowECO, filterVRP, lowDates);
        [midDiff, eco2] = volDiff(midECO, filterVRP, midDates);
        [highDiff, eco3] = volDiff(highECO, filterVRP, highDates);

        % split economic figures into positive and negative surprises
        [lowPosECO, lowNegECO] = ecoSplits(eco1, 'Surprise');
        [midPosECO, midNegECO] = ecoSplits(eco2, 'Surprise');
        [highPosECO, highNegECO] = ecoSplits(eco3, 'Surprise');

        % split vrp figures according to positive and negative surprises 
        [lowPosDiff, lowNegDiff] = volSplits(lowDiff, lowPosECO, ...
            lowNegECO, lowDates);
        [midPosDiff, midNegDiff] = volSplits(midDiff, midPosECO, ...
            midNegECO, midDates);
        [highPosDiff, highNegDiff] = volSplits(highDiff, highPosECO, ...
            highNegECO, highDates);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = {mean(lowPosDiff(:, :)), mean(lowNegDiff(:, :)); ...
            mean(midPosDiff(:, :)), mean(midNegDiff(:, :)); ...
            mean(highPosDiff(:, :)), mean(highNegDiff(:, :))};

        % computes the simple average acroos row (per each date) - returns
        % scaler representing average VRP change across time and security
        simpleAvg = [mean(y{1, 1}), mean(y{1, 2}); mean(y{2, 1}), ...
            mean(y{2, 2}); mean(y{3, 1}), mean(y{3, 2})];

        % plotting out the bucket changes by positive/negative leaning
        if ~isnan(simpleAvg)
            subplot(1, 2, index);
            bar(simpleAvg); title(strcat(rateNames(index), ...
                ' Rate Environment'));
            xticks([1, 2, 3]); xticklabels({'Low Std', 'Mid Std', ...
                'High Std'});
            ylim([min(min(simpleAvg))-0.5, max(max(simpleAvg))+0.5])
            xlabel('Forecast Standard Deviation', 'FontSize', 8);
            lgd = legend({'Positive Surprise', 'Negative Surprise'}, ...
                'Location', 'best'); 
            lgd.FontSize = 8;                                                       
        end
    end
    
    subplot(1, 2, 1);
    ylabel(strcat("Average VRP Change over ", econVars(i), " surprises"), ...
        'FontSize', 8);
    
    % export the image to Interest Bucket for VRP measures
    name = strcat("Output/MacroRegressions/vrpInterestBuckets/", ...
        event, ".jpg");
    exportgraphics(fig, name);
    
end

fprintf('VRP reponse graphs were created for interest rate regimes.\n');

addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'vrpInterestBuckets']) 

%% Timeseries of VRP changes by STD buckets 

for i = 1:10
    
    fig = figure('visible', 'off');                 
    set(gcf, 'Position', [100, 100, 800, 600]);   

    event = keys(i);
    
    % filter data by macro economic event
    filterData = ecoData(ismember(ecoData{:, 'Ticker'}, event), :);
    
    % compute the top quarter and bottom quarter forecast STD per event
    bottom25 = quantile(filterData.StdDev, .25);
    top25 = quantile(filterData.StdDev, .75);
    
    % bucket out economic figures according to std value
    lowECO = filterData((filterData.StdDev <= bottom25), :);
    midECO = filterData((top25 > filterData.StdDev) & ...
        (filterData.StdDev > bottom25), :);
    highECO = filterData((filterData.StdDev >= top25), :);
    
    % match target dates for each STD period 
    lowDates = matchingError(lowECO, vrp);
    midDates = matchingError(midECO, vrp);
    highDates = matchingError(highECO, vrp);
    
    % change in regressed values pre-post announcement 
    [lowDiff, eco1] = volDiff(lowECO, vrp, lowDates);
    [midDiff, eco2] = volDiff(midECO, vrp, midDates);
    [highDiff, eco3] = volDiff(highECO, vrp, highDates);
    
    % building out the average difference cell per STD period
    % function computes the mean, column wise (per each security) 
    y = {mean(lowDiff(:, :), 2), mean(midDiff(:, :), 2), ...
        mean(highDiff(:, :), 2)};
    
    % plotting out the bucket changes by positive/negative leaning
    hold on; 
    plot(eco1{:, 1}, y{1}, 'DisplayName', 'Low Std', 'Marker', 'o'); 
    plot(eco2{:, 1}, y{2}, 'DisplayName', 'Mid Std', 'Marker', 'd'); 
    plot(eco3{:, 1}, y{3}, 'DisplayName', 'High Std', 'Marker', 's'); 
    hold off; title(strcat(econVars(i), ' Forecast Impact'));
    ylabel('Average VRP Change over Period', 'FontSize', 8);
    legend('Location', 'best', 'FontSize', 8);                                                     
    
    % export the image to Interest Bucket for VRP measures
    name = strcat("Output/MacroRegressions/vrpBuckets/", ...
        event, " TS.jpg");
    exportgraphics(fig, name);
end

fprintf('VRP time series graphs were created.\n');

%% Function for Peforming Regressions on Macro Variables

function targetDates = matchingError(base, target)
%   Finds the intersection between both macro economic fields and the 
%   implied volatility/varaince risk premia levels provided
%   -------
%   :param: base   -> type table
%       Economic annoucments that track a particular event
%   :param: target -> type table
%       Target variable measure to track against economic event

   % annoucement data for economic measurements 
   annoucements = base{:, 1};

   % daily changes +/- day from release of annoucnemnt 
   % annoucement date EOD price - day prior EOD price
   post = target(ismember(target{:, 1}, annoucements), :);
   pre = target(ismember(target{:, 1}, annoucements-1), :);
   
   % find the intersection between date ranges
   targetDates = intersect(post{:, 1}, pre{:, 1}+1);
end


function [diff, eco] = volDiff(base, target, targetDate)
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
    eco = base(ismember(base{:, 1}, targetDate), :);
end


function [pos, neg] = ecoSplits(table, col)
%   Splits the economic table into positive and negative components that
%   adjust for surprises
%   -------
%   :param: table    -> type table

    pos = table(table{:, col} > 0, :);
    neg = table(table{:, col} < 0, :);
end


function [pos, neg] = volSplits(table, posEco, negEco, dates)
%   Splits the volatility table into days where economic surprises were 
%   positive and negative 
%   -------
%   :param: table    -> type table
%   :param: posEco   -> type table
%   :param: negEco   -> type table
%   :param: dates    -> type datetime vector

    pos = table(ismember(dates, posEco.DateTime), :);
    neg = table(ismember(dates, negEco.DateTime), :);
end


function concatTB = regression(X, y, col)
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

    % initialize memory for base table
    baseTB = zeros(size(keys, 2), 4);

    % large table for storing regression outputs
    concatTB = [];

    % iterate through each implied volatility measure (3 tenors, 4 terms) 
    for index = 1:12
        names = y.Properties.VariableNames{index+1};
        fprintf('Measure for %s swaption\n', names);

        % used to iterate through rows building table
        rows = 1;

        % iterate through each of the key annoucement events
        for i = keys
                
           try
               % filter out for particular economic data
               filterData = X(ismember(X{:, 'Ticker'}, i), :);

               % checking runtime of regressed values
               event = filterData{1, 'Event'}; 
               fprintf('\tRegressing on %s\n', event{:});

               % find the intersection between date ranges
               targetDates = matchingError(filterData, y);
                
               % computes difference and economic surprise
               [diff, eco] = volDiff(filterData, y, targetDates);

               % perform linear regression with significance
               mdl = fitlm(eco{:, col}, diff(:, index));

               % select model specifications for each regression 
               baseTB(rows, :) = mdl.Coefficients{2,:}; 
               rows = rows + 1;

           catch
               fprintf('\nError looking to split %s\n', i{:});
               
           end
           
        end

        % export table to .csv
        exportTB = array2table(baseTB);
        exportTB.Properties.VariableNames = {'Estimate', 'SE', ...
            'tStat', 'pValue'};
        
        % add additional columns for events and security name
        exportTB.Event = keys';
        exportTB.Security = {names, names, names, names, names, ...
            names, names, names, names, names}';

        % concat vertically the dimension of the table
        concatTB = [concatTB; exportTB];
        
    end
    
end


function termStructure(tb, folder, keys, econVars)
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
        ylabel('Regression Coefficient', 'FontSize', 8);
        title(econVars(i));

        % show the legend for the underlying series
        lgd = legend(); lgd.FontSize = 7;   
        hold off; 
        
        exportName = strcat(directory, event, '.jpg');
        exportgraphics(fig, exportName);
    end

end

