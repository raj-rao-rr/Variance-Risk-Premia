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
out_std_dir = "Output/macro-announcements/std-buckets/";

% some global variables
eventList = ecoMap.keys;

swap2y = {'USSV0C2Curncy', 'USSV0F2Curncy', 'USSV012Curncy', ...
    'USSV022Curncy'};
swap5y = {'USSV0C5Curncy', 'USSV0F5Curncy', 'USSV015Curncy', ...
    'USSV025Curncy'};
swap10y = {'USSV0C10Curncy', 'USSV0F10Curncy', 'USSV0110Curncy', ...
    'USSV0210Curncy'};

swap3m = {'USSV0C2Curncy', 'USSV0C5Curncy', 'USSV0C10Curncy'};
swap6m = {'USSV0F2Curncy', 'USSV0F5Curncy', 'USSV0F10Curncy'};
swap12m = {'USSV012Curncy', 'USSV015Curncy', 'USSV0110Curncy'};
swap24m = {'USSV022Curncy', 'USSV025Curncy', 'USSV0210Curncy'};

%% Construct Standard Deviation Bucket graphs, by swap term and tenor

% iterate through events
for event = eventList
    
    window = 1;     % window for computing difference 
    
    % filter the accompanying event for the economic deviation
    ecoBin1 = ecoSTD25(ismember(ecoSTD25.Event, event), :);
    ecoBin2 = ecoSTD75(ismember(ecoSTD75.Event, event), :);
    
    % find the intersection between date ranges of X and y variables
    targetDates1 = matchingError(ecoBin1, blackVol, window);
    targetDates2 = matchingError(ecoBin2, blackVol, window);

    % computes difference and economic surprise
    [diff1, ~] = differenceSplit(ecoBin1, blackVol, targetDates1, window);
    [diff2, ~] = differenceSplit(ecoBin2, blackVol, targetDates2, window);
    
    % compute the mean of each difference across tenor filter
    lowUncTerm = [mean(mean(diff1{:, swap2y})), mean(mean(diff1{:, swap5y})), ...
        mean(mean(diff1{:, swap10y}))];
    highUncTerm = [mean(mean(diff2{:, swap2y})), mean(mean(diff2{:, swap5y})), ...
        mean(mean(diff2{:, swap10y}))];
    
    lowUncTenor = [mean(mean(diff1{:, swap3m})), mean(mean(diff1{:, swap6m})), ...
        mean(mean(diff1{:, swap12m})), mean(mean(diff1{:, swap24m}))];
    highUncTenor = [mean(mean(diff2{:, swap3m})), mean(mean(diff2{:, swap6m})), ...
        mean(mean(diff2{:, swap12m})), mean(mean(diff2{:, swap24m}))];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plotting apparatus for std
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fig = figure('visible', 'off');                  % prevent display
    set(gcf, 'Position', [100, 100, 1450, 750]);    % setting figure dim
    name = event{:}; 
    
    row1 = ["Low Uncertainity", "High Uncertainity"];
    row2 = [strcat("(25 pct, ", string(size(diff1, 1)), " obs)"), ...
        strcat("(75 pct, ", string(size(diff2, 1)), " obs)")];
    labelArray = [row1; row2];
    tickLabels = strtrim(sprintf('%s\\newline %s\n', labelArray{:}));
    
    subplot(1, 2, 1)
    bar([lowUncTerm; highUncTerm]);
    legend('show', {'2y Term', '5y Term', '10 Term'}, 'Location', 'southoutside', ...
        'Orientation', 'horizontal', 'FontSize', 9)
    xticklabels(tickLabels)
    ylabel('Average Change in Implied Volatility Response', 'FontSize', 9)
    title({"Swaption response to Economic Annoucment", name})

    subplot(1, 2, 2)
    bar([lowUncTenor; highUncTenor]);
    legend('show', {'3m Tenor', '6m Tenor', '12m Tenor', '24m Tenor'}, ...
        'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 9)
    xticklabels(tickLabels)
    ylabel('Average Change in Implied Volatility Response', 'FontSize', 9)
    title({"Swaption response to Economic Annoucment", name})
    
    % export figure to correct directory
    exName = strcat(out_std_dir, "iv/", event, " (std).jpg");
    exportgraphics(fig, exName{:});
end

%% Construct Standard Deviation Bucket graphs, by swap term and tenor

% iterate through events
for event = eventList
    
    window = 1;     % window for computing difference 
    
    % filter the accompanying event for the economic deviation
    filterEco = cleanEco(ismember(cleanEco.Event, event), :);
    
    % filter the accompanying event for the interest rate regime
    ecoBin1 = filterEco(ismember(filterEco.DateTime, lowIR.DATE), :);
    ecoBin2 = filterEco(ismember(filterEco.DateTime, highIR.DATE), :);
    
    % find the intersection between date ranges of X and y variables
    targetDates1 = matchingError(ecoBin1, blackVol, window);
    targetDates2 = matchingError(ecoBin2, blackVol, window);

    % computes difference and economic surprise
    [diff1, ~] = differenceSplit(ecoBin1, blackVol, targetDates1, window);
    [diff2, ~] = differenceSplit(ecoBin2, blackVol, targetDates2, window);
    
    % compute the mean of each difference across tenor filter
    lowUncTerm = [mean(mean(diff1{:, swap2y})), mean(mean(diff1{:, swap5y})), ...
        mean(mean(diff1{:, swap10y}))];
    highUncTerm = [mean(mean(diff2{:, swap2y})), mean(mean(diff2{:, swap5y})), ...
        mean(mean(diff2{:, swap10y}))];
    
    lowUncTenor = [mean(mean(diff1{:, swap3m})), mean(mean(diff1{:, swap6m})), ...
        mean(mean(diff1{:, swap12m})), mean(mean(diff1{:, swap24m}))];
    highUncTenor = [mean(mean(diff2{:, swap3m})), mean(mean(diff2{:, swap6m})), ...
        mean(mean(diff2{:, swap12m})), mean(mean(diff2{:, swap24m}))];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plotting apparatus for std
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fig = figure('visible', 'off');                  % prevent display
    set(gcf, 'Position', [100, 100, 1450, 750]);    % setting figure dim
    name = event{:}; 
    
    row1 = ["Low Rate Enviornment", "High Rate Enviornment"];
    row2 = [strcat("     (< 2%, ", string(size(diff1, 1)), " obs)"), ...
        strcat("      (\geq 2%, ", string(size(diff2, 1)), " obs)")];
    labelArray = [row1; row2];
    tickLabels = strtrim(sprintf('%s\\newline %s\n', labelArray{:}));
    
    subplot(1, 2, 1)
    bar([lowUncTerm; highUncTerm]);
    legend('show', {'2y Term', '5y Term', '10 Term'}, 'Location', 'southoutside', ...
        'Orientation', 'horizontal', 'FontSize', 9)
    xticklabels(tickLabels)
    ylabel('Average Change in Implied Volatility Response', 'FontSize', 9)
    title({"Swaption response to Economic Annoucment", name})

    subplot(1, 2, 2)
    bar([lowUncTenor; highUncTenor]);
    legend('show', {'3m Tenor', '6m Tenor', '12m Tenor', '24m Tenor'}, ...
        'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 9)
    xticklabels(tickLabels)
    ylabel('Average Change in Implied Volatility Response', 'FontSize', 9)
    title({"Swaption response to Economic Annoucment", name})
    
    % export figure to correct directory
    exName = strcat(out_std_dir, "iv/", event, "(rate).jpg");
    exportgraphics(fig, exName{:});
end

%%

fprintf('Construct bucket graphs by swap term and tenor.\n')