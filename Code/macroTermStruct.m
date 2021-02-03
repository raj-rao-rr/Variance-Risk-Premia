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
out_tms_dir = 'Output/macro-announcements/term-structure/';

% some global variables
eventList = ecoMap.keys;

%%

% compute pivot table with index of DateTime, columns Events
X = pivotTable(cleanEco, 'SurpriseZscore', 'DateTime', 'Event');
y = yeildCurve; 
window = 1;

% find the intersection between date ranges of X and y variables
targetDates = matchingError(X, y, window);

% computes difference and economic surprise
[diff, eco] = differenceSplit(X, y, targetDates, window);

% fit the linear model for each y-value provided 
mdl1 = fitlm(eco{:, 2:end}, diff{:, 4});
mdl2 = fitlm(eco{:, 2:end}, diff{:, 3});
mdl3 = fitlm(eco{:, 2:end}, diff{:, 2});

fig = figure('visible', 'on');                 % prevent display 
set(gcf, 'Position', [100, 100, 1750, 450]);    % setting figure dimensions

subplot(1, 3, 1)
hold on
plot(eco{:, 1}, diff{:, 4}, 'LineWidth', 1, 'DisplayName', 'Actual')
plot(eco{:, 1}, mdl1.Fitted, 'LineWidth', 1, 'DisplayName', 'Fitted')
ylabel('Daily Changes')
legend show
hold off

subplot(1, 3, 2)
hold on
plot(eco{:, 1}, diff{:, 3}, 'LineWidth', 1, 'DisplayName', 'Actual')
plot(eco{:, 1}, mdl2.Fitted, 'LineWidth', 1, 'DisplayName', 'Fitted')
legend show
hold off

subplot(1, 3, 3)
hold on
plot(eco{:, 1}, diff{:, 2}, 'LineWidth', 1, 'DisplayName', 'Actual')
plot(eco{:, 1}, mdl3.Fitted, 'LineWidth', 1, 'DisplayName', 'Fitted')
legend show
hold off


%% Construct term structure graphs 

volData = {blackVol, vrp};
volFolder = {'iv', 'vrp'};

% iterate through various volatility measures
for data = 1:2
    
    % volatility data being examined
    vol = volData{data};
    volName = volFolder(data);
    
    for event = eventList
        fig = figure('visible', 'off');  
        set(gcf, 'Position', [100, 100, 1250, 600]);

        name = event{:};
        eventName = ecoMap(name); period = 1;

        % filter economic dates according to interest rate regime 
        filterLowEco = ecoData(ismember(ecoData{:, 1}, lowIR{:, 1}), :);
        filterHighEco = ecoData(ismember(ecoData{:, 1}, highIR{:, 1}), :);

        % filter economic data according to appropriate event
        filterLowData=filterLowEco(strcmp(filterLowEco.Ticker,event), :);
        filterHighData=filterHighEco(strcmp(filterHighEco.Ticker,event),:);

        % match target dates according to the date prior examined
        targetLowDate = matchingError(filterLowData, vol, period);
        targeHighDate = matchingError(filterHighData, vol, period);

        % select dates of pre/post annoucment window for vol measures
        afterLowAnnouce = vol(ismember(vol{:, 1}, ...
            targetLowDate), :);
        beforeLowAnnouce = vol(ismember(vol{:, 1}, ...
            targetLowDate-period), :);

        afterHighAnnouce = vol(ismember(vol{:, 1}, ...
            targeHighDate), :);
        beforeHighAnnouce = vol(ismember(vol{:, 1}, ...
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
        filename = strcat(out_tms_dir, volName{:}, "/", event, '.jpg');
        
        exportgraphics(fig, filename);
        
    end
    
end

fprintf('Term structure graph around macro-annoucement created.\n')