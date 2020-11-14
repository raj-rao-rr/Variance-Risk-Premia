% Generates graphs that pertain to volatility, both implied and realized

clear; 

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol treasuryData vixData


% defines the date index for volatility measures
date = blackVol{:,1};

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 1y; 2y
termsID = ["3M", "6M", "1Y", "2Y"];


%% (Figure 1) Swaption Implied Volatilities 

fig = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 950, 650]);    % setting figure dimensions

left_color = [0 0 0];           % RGB for black
right_color = [0 .5 .5];        % RGB for darker cyan

% setting the color of the subplots axis
set(f1,'defaultAxesColorOrder', [left_color; right_color]);

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
    title(strcat("Swap IV Term ", termsID(i), " vs 10y Treasury"));
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ... 
                 'US Govt 10Y Index (Right)');
    lgd.FontSize = 8;       % setting the font-size of the legend
    hold off; 
end

exportgraphics(fig, 'Output/figure1.jpg');
fprintf('Swaption volatility graph was created.\n');

%% (Figure 2) Cross Section of Swaption Implied Volatilities


%% (Figure 13) Swaption Implied Vol vs. VIX

fig = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 950, 650]);   % setting figure dimensions

for i = 1:4
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    % select the appropriate VIX measure to compare swap vols
    vixMeasure = vixData{:, 2};
    
    % select the appropriate swap iv terms
    volMeasure = blackVol{:, [swap2y, swap5y, swap10y]};
    
    % plotting volatility graph across term structure
    subplot(2,2,i);
    plot(blackVol.Date, volMeasure); hold on 
    
    % plot the VIX measure on a seperate axis
    yyaxis right;
    plot(vixData.Date, vixMeasure, 'LineWidth', 1); hold off; 
    title(strcat("Swap IV Term ", termsID(i), " vs VIX"));
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ... 
                 strcat("VIX Index", ' (right)'), ...
                 'Location', 'northwest');
    lgd.FontSize = 8;       % setting the font-size of the legend
end

exportgraphics(fig, 'Output/figure13.jpg');
fprintf('VIX comparison graphs were created.\n');

%% (Figure 7) Swaption Implied Vol Structural Breaks 

% Structural break points (in black dashed vertical lines),
% determined by the methods developed in (Bai and Perron, 1998).

