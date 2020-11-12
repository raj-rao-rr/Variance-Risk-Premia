% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and implied volatility data
load DATA ecoData keys blackVol econVars

load SigA SigA 

% loading in VRP measures
load VRP vrp


%% Initialization of variables and directories

% check to see if the directory exists, if not create it
if ~exist('Output/MacroRegressions/', 'dir')
    mkdir Output/MacroRegressions/                                         
end

% check to see if the directory exists, if not create it
if ~exist('Output/MacroRegressions/Buckets/', 'dir')
    mkdir Output/MacroRegressions/Buckets/                                         
end

addpath([root_dir filesep 'Output' filesep 'MacroRegressions'])             % add the paths for regression data
addpath([root_dir filesep 'Output' filesep 'MacroRegressions' filesep ...
    'Buckets'])                                                             % add the paths for std buckets

%% Regression on Macro surprises 

concatTB = regression(ecoData, vrp);

writetable(concatTB, 'Output/MacroRegressions/vrpRegress.csv');
disp('Macro regression .csv was created...');

%% Regression against underlying black-scholes implied volatility 

concatTB = regression(ecoData, blackVol);

writetable(concatTB, 'Output/MacroRegressions/ivRegress.csv');
fprintf('Black volatility regression .csv was created.\n');

%% Regression against underlying forecasted realized volatility 

concatTB = regression(ecoData, SigA);

writetable(concatTB, 'Output/MacroRegressions/rvRegress.csv');
fprintf('GARCH forecasted volatility regression .csv was created.\n');

%% Tenor Structure for Events (using VRP)

% load in data from VRP regressed values 
vrpRegress = readtable('vrpRegress.csv');
ivRegress = readtable('blackVolRegress.csv');
rvRegress = readtable('garchRegress.csv');

termStructure(vrpRegress, "vrp_term_struct.jpg", 'off');
termStructure(ivRegress, "iv_term_struct.jpg", 'off');
termStructure(rvRegress, "rv_term_struct.jpg", 'off');

fprintf('pValue Term structure graphs were created.\n');

%% VRP buckets by STD (low 25% vs high 75%)

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
    ylabel('Average VRP Change over Period');
    lgd = legend({'Positive Surprise', 'Negative Surprise'}, ...
        'Location', 'best'); 
    lgd.FontSize = 8;                                                       
    
    name = strcat("Output/MacroRegressions/Buckets/", event, ".jpg");
    exportgraphics(fig, name);
end

fprintf('VRP bucket reponse grpah were created.\n');

%% Function for Peforming Regressions on Macro Variables

function targetDates = matchingError(base, target)
%   Finds the intersection between both macro economic fields and the 
%   implied volatility/varaince risk premia levels
%   -------
%   :param: base   -> type table
%   :param: target -> type table

   % annoucement data for economic measurements 
   annoucements = base{:, 1};

   % daily changes +/- day of release of annoucnemnt 
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
%   :param: target     -> type table
%   :param: targetDate -> type datetime array

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


function concatTB = regression(X, y)
%   Peforms a regression on varaibles X, y. Where X is a table of economic  
%   data releases provided by Bloomberg and y is the measured target. 
%   These targets include our measure for Variance Risk premia, implied
%   volatility and realized volatiltity 
%   -------
%   :param: X -> type table
%   :param: y -> type table

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
               mdl = fitlm(eco{:, 'Surprise'}, diff(:, index));

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


function termStructure(tb, fileName, show)
%   Plots the term structure of p-Values for volatility measures regressed
%   on economic surprises for a given security tier
%   -------
%   :param: tb       -> type table
%   :param: fileName -> type str (double qoutes "..")
    
    if contains(show, 'on')
        fig = figure('visible', 'on');                                       
    else
        fig = figure('visible', 'off');
    end
    
    set(gcf, 'Position', [100, 100, 1250, 900]);                            % setting figure dimensions
    
    keys = unique(tb{:, 'Event'})';
    
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

        % vrp regression filtered by security and event
        x2y = tb(ismember(tb{:, 'Security'}, tier1) ...
            & ismember(tb{:, 'Event'}, event), :);
        x5y = tb(ismember(tb{:, 'Security'}, tier2) ...
            & ismember(tb{:, 'Event'}, event), :);
        x10y = tb(ismember(tb{:, 'Security'}, tier3) ...
            & ismember(tb{:, 'Event'}, event), :);

        % construct the new modified subplots
        subplot(5,2,i); hold on;
        plot(x2y{:, 'Estimate'}, 'DisplayName', '2y Tenor', 'color', ...
            'red', 'Marker', 'o');
        plot(x5y{:, 'Estimate'}, 'DisplayName', '5y Tenor', 'color', ...
            'green', 'Marker', '+');
        plot(x10y{:, 'Estimate'}, 'DisplayName', '10y Tenor', 'color', ...
            'blue', 'Marker', 'x');
        xticks([1, 2, 3, 4]); xticklabels({'3m', '6m', '1y', '2y'});
        ylabel('Regression Coefficient');
        title(event);

        % show the legend for the underlying series
        lgd = legend(); lgd.FontSize = 7;   
        hold off; 
    end
    
    exportName = strcat("Output/MacroRegressions/", fileName);
    exportgraphics(fig, exportName);

end
