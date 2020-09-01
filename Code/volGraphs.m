% Generates graphs that pertain to volatility, both implied and realized

clear; 

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol treasuryData vixData


% defines the date index for volatility measures
date = blackVol{:,1};

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 1y; 2y
termsID = ["3M", "6M", "1Y", "2Y"];


%% Black Vol versus Normal Vol

f0 = figure('visible', 'off'); hold on; 
set(gcf, 'Position', [100, 100, 950, 650]);    % setting figure dimensions

blackVolName = strcat("USSV", terms(1), tenors(1), "Curncy");
normalVolName = strcat("USSN", terms(1), tenors(1), "Curncy");

plot(blackVol{:,1}, ...
    blackVol{:, blackVol.Properties.VariableNames == blackVolName}, ...
    'DisplayName', 'Black-Scholes Implied Vol');
plot(normalVol{:,1}, ...
    normalVol{:, normalVol.Properties.VariableNames == normalVolName}, ...
    'DisplayName', 'Normal Implied Vol');

legend show; hold off; 

exportgraphics(f0, 'Output/black_normal_vol.jpg');
disp('Implied Vol comparisons were created...');


%% Swaption Implied Volatilities (Figure 1)

f1 = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 950, 650]);    % setting figure dimensions

left_color = [0 0 0];           % RGB for black
right_color = [0 .5 .5];        % RGB for darker cyan

% setting the color of the subplots axis
set(f1,'defaultAxesColorOrder',[left_color; right_color]);

for i = 1:4
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    % construct the new modified subplots
    subplot(2,2,i); hold on; 
    
    % plotting the swap IV data for each tenor at a term 
    plot(date, blackVol{:,swap2y}, 'color', 'blue');
    plot(date, blackVol{:,swap5y}, 'color', '#77AC30'); 
    plot(date, blackVol{:,swap10y}, 'color', 'red');
    
    % plotting the 10y Treasury rate on seperate y-axis
    yyaxis right;
    plot(table2array(treasuryData(:,1)),table2array(treasuryData(:,2)), ...
          'Linestyle', '--', 'color', right_color);
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ... 
                 'US Govt 10Y Index (Right)');
    lgd.FontSize = 8;       % setting the font-size of the legend
    hold off; 
end

exportgraphics(f1, 'Output/swaption_implied_volatilities.jpg');
disp('Swaption vol graph was created...');


%% Swaption Implied Volatility Term Structure (specific periods)

% Work on expanding this to be more generic highlighting periods of high
% volatility on a dynamic date index 

f2 = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1250, 900]);   % setting figure dimensions

% periods of interest (naming conventions for period preserved)
lehmanStart=find(date=="9/09/2008"); lehmanEnd=find(date=="10/09/2008");
covidStart=find(date=="2/28/2020"); covidEnd=find(date=="4/3/2020");

for i = 1:4
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    lehmanData = blackVol(lehmanStart:lehmanEnd, :);  % Lehman colapse
    covidData = blackVol(covidStart:covidEnd, :);     % COVID-19 outbreak
    currData = blackVol(end-21:end, :);               % Last 21-day horizon
    
    % filter data table for swap terms over the crisis periods
    lehmanCurve = lehmanData{:, [swap2y, swap5y, swap10y]};
    covidCurve = covidData{:, [swap2y, swap5y, swap10y]};
    currCurve = currData{:, [swap2y, swap5y, swap10y]};
    
    % plotting the tenor structure of the swaption IVs over the periods
    
    % --------------------------
    % Lehamn Brothers collapse
    % --------------------------
    subplot(3,2,1); hold on;
    title("Lehman Collapse (9/09/2008 - 10/09/2008)");
    plot(1:3, mean(lehmanCurve, 1), ... 
        'LineWidth', 1, 'Marker', 'o', 'DisplayName', termsID(i));
    xticks(1:3); xticklabels(["2y", "5y", "10y"]);  
    legend('show'); 
    
    subplot(3,2,2); hold on;
    title('Implied Volatilities over crisis periods');
    samePlot(lehmanData, lehmanCurve, termsID(i));  
    
    % --------------------------
    % COVID-19 equity collapse
    % --------------------------
    subplot(3,2,3); hold on;
    title("COVID-19 Pandemic (2/28/2020 - 3/27/2020)");
    plot(1:3, mean(covidCurve, 1), ...
        'LineWidth', 1, 'Marker', 'o', 'DisplayName', termsID(i));
    xticks(1:3); xticklabels(["2y", "5y", "10y"]);
    legend('show');
    
    subplot(3,2,4); hold on;
    samePlot(covidData, covidCurve, termsID(i));  
    
    % --------------------------
    % Last 21 Trailing days
    % --------------------------
    subplot(3,2,5); hold on;
    title("Current period (6/11/2020 - 7/14/2020)");
    plot(1:3, mean(currCurve, 1), ...
        'LineWidth', 1, 'Marker', 'o', 'DisplayName', termsID(i));
    xticks(1:3); xticklabels(["2y", "5y", "10y"]);
    legend('show');
    
    subplot(3,2,6); hold on;
    samePlot(currData, currCurve, termsID(i));
    xlim([date(end-21), date(end)]);
end
hold off;

exportgraphics(f2, 'Output/swaption_iv_term_structure.jpg');
disp('Swaption term structure was created...');


%% Swaption Implied Vol vs. VIX

f3 = figure('visible', 'on');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1250, 900]);   % setting figure dimensions

for i = 1:3
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    % select the appropriate VIX measure to compare swap vols
    vixMeasure = vixData{:, 2};
    
    % select the appropriate swap iv terms
    volMeasure = blackVol{:, [swap2y, swap5y, swap10y]};
    
    % plotting volatility graph across term structure
    subplot(3,1,i);
    plot(blackVol.Date, volMeasure); hold on 
    
    % plot the VIX measure on a seperate axis
    yyaxis right;
    plot(vixData.Date, vixMeasure, 'LineWidth', 2); hold off; 
    title(strcat("Swap IV Term", termsID(i), " vs VIX ", termsID(i)));
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ... 
                 strcat("VIX Index", ' (right)'), ...
                 'Location', 'northwest');
    lgd.FontSize = 8;       % setting the font-size of the legend
end

exportgraphics(f3, 'Output/vix_vs_iv.jpg');
disp('VIX comparison graphs were created...');


%% Swaption Implied Vol Structural Breaks (Figure 7)

% Structural break points (in black dashed vertical lines),
% determined by the methods developed in (Bai and Perron, 1998).


%% Helper Functions

function samePlot(dataTable, filterArray, term)
% samePlot used for plotting IV graphs of varying tenor, 'same' term 
%    :param: dataTable is of type table
%    :param: filterArray is of type double array
%    :param: term is of type string
%  this function is void and returns no value

    % error handling for parameters
    assert(isa(dataTable, 'table'), "Parameter must be of type table");
    assert(isa(filterArray, 'double'), 'Parameter must be of type double'); 
    assert(isa(term, 'string'), "Parameter must be of type string");
    
    % plotting the given term plots 
    plot(dataTable.Date, filterArray(:,1), ...
         'LineStyle', '--', ...
         'DisplayName', strcat("2y",term));
    plot(dataTable.Date, filterArray(:,2), ...
         'LineWidth', 2, ...
         'DisplayName', strcat("5y",term));
    plot(dataTable.Date, filterArray(:,3), ...
         'LineStyle', ':', ...
         'LineWidth', 2, ...
         'DisplayName', strcat("10y",term));
    lgd = legend; lgd.FontSize = 6;
end