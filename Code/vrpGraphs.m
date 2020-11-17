% Generates graphs that pertain to displaying the variance risk premium

clear; 

load INIT root_dir

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol treasuryData vixData swapData fedfunds ...
    lowIR highIR

% loading in temp file for GARCH forecasts
load SigA SigA LB UB
load FSigmaF SigmaFA LBFA UBFA

% loading in VRP measures
load VRP vrp


%% Common global variables

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 1y; 2y
termsID = ["3M", "6M", "1Y", "2Y"];

% security names for swaps 2y-10y
names = vrp.Properties.VariableNames(2:end);

%% (Figure 3) Swaption Implied Vol vs. Forecasted Real Vol 

% check to see if the directory exists, if not create it
if ~exist('Output/garchForecasts/', 'dir')
    mkdir Output/garchForecasts/                                         
end

% incrementing across each tenor (e.g. 2y, 5y)
for i = 1:3
    
    fig = figure('visible', 'off');                                         % prevent display to MATLAB
    set(gcf, 'Position', [100, 100, 1250, 900]);                            % setting figure dimensions
    
    % incrementing across each term (e.g. 3m, 24m)
    for j = 1:4
        
        % naming convention for swap securities 
        index = strcat("USSV", terms(j), tenors(i), "Curncy");
    
        ref1 = ismember(blackVol{:,1}, SigA{:,1});                          % matching the forecast length to IV data
        ref2 = ismember(SigA{:,1}, blackVol{:,1});                          % matching the forecast length to IV data
        date = blackVol{ref1,1};                                            % defines the date index for vol forecasts
        
        % GARCH annualized measures 
        upper = UB{ref2, index};    % 97.5th percentile GARCH sim
        mid = SigA{ref2, index};    % mean / 50th percentile
        lower = LB{ref2, index};    % 2.5th percentile GARCH sim
        
        % implied volatility data (black-scholes)  
        iv = blackVol{ref1, index};                                            

        h = zeros(1,4);            % plot-figure object matrix
        
        % construct the new modified subplots
        subplot(4,1,j); hold on; 

        % plot forecasted volatility against swaption IV
        h(1,1) = plot(date, upper, 'DisplayName', '95% Bounds', ...
            'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5); 
        h(1,2) = plot(date, iv, 'DisplayName', 'E[\sigma^Q]', ...
            'Color', 'b'); 
        h(1,3) = plot(date, mid, 'DisplayName', 'E[\sigma^P]', ...
            'Color', 'r'); 
        h(1,4) = plot(date, lower, 'DisplayName', '95% Bounds', ...
            'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5); 
        
        title(strcat("Tenor ", tenors(i), "Y, Term ", termsID(j)));         % specify legend to match tenor and term
        hold off; legend(h(2:end), 'Location', 'northwest');                % specify the legend displays
    end
    
    outputFileName = strcat("Output/garchForecasts/Tenor", ...             % the name of the output file 
            tenors(i), "y.png"); 
    exportgraphics(fig, outputFileName);
end

addpath([root_dir filesep 'Output' filesep 'garchForecasts'])               % add the paths of GARCH forecast graphs
fprintf('GARCH graphs were created.\n');

%% (Figure 4) Variance Risk Premia 

fig = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1050, 850]);   % setting figure dimensions

for i = 1:4
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    % construct the new modified subplots
    subplot(2,2,i); hold on; 
    
    % defines the date index for volatility measures
    date = vrp{:,1};
    
    % compute the average VRP over the plot period
    avgVRP = mean(mean(vrp{:, [swap2y, swap5y, swap10y]}, 2));
    % disp(avgVRP)
    
    % plotting the vrp measures for each tenor at a term 
    plot(date, vrp{:, swap2y}, 'color', 'blue');
    plot(date, vrp{:, swap5y}, 'color', 'red'); 
    plot(date, vrp{:, swap10y}, 'color', 'green');
    plot(date, ones(1, length(date))*avgVRP, 'color', 'black', ...
        'linestyle', '--', 'linewidth', 2);
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ...
                 'Location', 'northwest');
    lgd.FontSize = 8;       % setting the font-size of the legend
    hold off; 
end

exportgraphics(fig, 'Output/figure4.jpg');
fprintf('Variance Risk Premia graph was created.\n');

%% (Figure 5) Autocorrelation Function for Variance Risk Premia 

% check to see if the directory exists, if not create it
if ~exist('Output/Autocorrelations/', 'dir')
    mkdir Output/Autocorrelations/                                         
end

for n = 1:length(names)
    fig = figure('visible', 'off');                
    set(gcf, 'Position', [100, 100, 1050, 850]);   

    % plotting the autocorrelation of each VRP measure 
    autocorr(vrp{:, names(n)}, 'NumLags', 50);  
    
    outputFileName = strcat("Output/Autocorrelations/", ...
        names(n), ".jpg");                                                  % the name of the output file 
          
    exportgraphics(fig, outputFileName);
end

addpath([root_dir filesep 'Output' filesep 'Autocorrelations'])             % add the paths of autocorrelation folder
fprintf('Autocorrelation graphs were created.\n');

%% (Figure 6) Swaption Variance Risk Premia vs VIX 

fig = figure('visible', 'off');                 % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1050, 850]);   % setting figure dimensions

for i = 1:3
    % construct the names for each swaption tenor 
    swap2y  = strcat("USSV", terms(i), tenors(1), "Curncy");
    swap5y  = strcat("USSV", terms(i), tenors(2), "Curncy");
    swap10y = strcat("USSV", terms(i), tenors(3), "Curncy");
    
    % construct the new modified subplots
    subplot(3,1,i); hold on; 
    
    % defines the date index for volatility measures
    date = vrp{:,1};
    
    % plotting the vrp measures for each tenor at a term 
    plot(date, vrp{:, swap2y}, 'DisplayName', ...
        strcat("2y,", termsID(i)), 'color', [0, 0.4470, 0.7410]);
    plot(date, vrp{:, swap5y}, 'DisplayName', ...
        strcat("5y,", termsID(i)), 'color', [0.8500, 0.3250, 0.0980]); 
    plot(date, vrp{:, swap10y}, 'DisplayName', ...
        strcat("10y,", termsID(i)), 'color', 'green');

    % plot the VIX measure
    plot(vixData{:, 1}, vixData{:, 2}, ...                                  % selecting date range to match IV measures
        'DisplayName', 'VIX Index', 'color', 'black');
    
    legend('show', 'location', 'southwest', 'fontsize', 7);
    hold off; 
end

exportgraphics(fig, 'Output/figure6.jpg');
fprintf('VRP vs. VIX graphs were created.\n');

%% (Figure 8) Cross-Section of Variance Risk Premia by Subsamples

fig = figure('visible', 'off');                % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1050, 850]);   % setting figure dimensions

subplot(3, 1, 1);
lowVRP = vrp(ismember(vrp{:, 1}, lowIR{:, 1}), :);
Y = reshape(mean(lowVRP{:, 2:end}), 4, 3)';     % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '3m', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '6m', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '12m', 'color', 'green', 'marker', 'd');
plot(Y(:,4), '-.','DisplayName', '24m', 'color', 'magenta', 'marker', '*');
hold off;
xticks([1, 2, 3]); xticklabels({'2y', '5y', '10y'});
title('High Interest Subsample');
legend('location', 'best');

subplot(3, 1, 2);
highVRP = vrp(ismember(vrp{:, 1}, highIR{:, 1}), :);
Y = reshape(mean(highVRP{:, 2:end}), 4, 3)';     % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '3m', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '6m', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '12m', 'color', 'green', 'marker', 'd');
plot(Y(:,4), '-.','DisplayName', '24m', 'color', 'magenta', 'marker', '*');
hold off;
xticks([1, 2, 3]); xticklabels({'2y', '5y', '10y'});
title('Low Interest Subsample');
legend('location', 'best');

subplot(3, 1, 3);
Y = reshape(mean(vrp{:, 2:end}), 4, 3)';        % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '3m', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '6m', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '12m', 'color', 'green', 'marker', 'd');
plot(Y(:,4), '-.','DisplayName', '24m', 'color', 'magenta', 'marker', '*');
hold off;
xticks([1, 2, 3]); xticklabels({'2y', '5y', '10y'});
title('Full Subsample'); xlabel('Tenor (in years)');
legend('location', 'best');

exportgraphics(fig, 'Output/figure8.jpg');
fprintf('Cross-Section of Variance Risk Premia were created.\n');

%% (Figure 9) Term Structure of Variance Risk Premia by Subsamples

fig = figure('visible', 'off');                % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1050, 850]);   % setting figure dimensions

subplot(3, 1, 1);
lowVRP = vrp(ismember(vrp{:, 1}, lowIR{:, 1}), :);
Y = reshape(mean(lowVRP{:, 2:end}), 4, 3);     % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '2y', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '5y', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '10y', 'color', 'green', 'marker', 'd');
hold off;
xticks([1, 2, 3, 4]); xticklabels({'3m', '6m', '12m', '24m'});
title('High Interest Subsample');
legend();

subplot(3, 1, 2);
highVRP = vrp(ismember(vrp{:, 1}, highIR{:, 1}), :);
Y = reshape(mean(highVRP{:, 2:end}), 4, 3);     % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '2y', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '5y', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '10y', 'color', 'green', 'marker', 'd');
hold off;
xticks([1, 2, 3, 4]); xticklabels({'3m', '6m', '12m', '24m'});
title('Low Interest Subsample');
legend();

subplot(3, 1, 3);
Y = reshape(mean(vrp{:, 2:end}), 4, 3);         % plotting values
hold on;
plot(Y(:,1), '-.', 'DisplayName', '2y', 'color', 'blue', 'marker', 's');
plot(Y(:,2), '-.','DisplayName', '5y', 'color', 'red', 'marker', 'o');
plot(Y(:,3), '-.', 'DisplayName', '10y', 'color', 'green', 'marker', 'd');
hold off;
xticks([1, 2, 3, 4]); xticklabels({'3m', '6m', '12m', '24m'});
title('Full Subsample'); xlabel('Term (in months)');
legend();

exportgraphics(fig, 'Output/figure9.jpg');
fprintf('Term Structure of Variance Risk Premia was created.\n');
