% Generates graphs that pertain to displaying the variance risk premium

clear; 

load INIT root_dir

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol treasuryData vixData swapData

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

%% Swaption Implied Vol vs. Forecasted Real Vol (Figure 3)

% check to see if the directory exists, if not create it
if ~exist('Output/GARCH_Forecasts/', 'dir')
    mkdir Output/GARCH_Forecasts/                                         
end

% incrementing across each tenor (e.g. 2y, 5y)
for i = 1:3
    
    fig = figure('visible', 'off');                                         % prevent display to MATLAB
    set(gcf, 'Position', [100, 100, 1250, 900]);                            % setting figure dimensions
    
    % incrementing across each term (e.g. 3m, 24m)
    for j = 1:4
        
        % naming convention for swap securities 
        index = strcat("USSV", terms(j), tenors(i), "Curncy");
    
        ref1 = ismember(blackVol{:,1}, SigA{:,end});                        % matching the forecast length to IV data
        ref2 = ismember(SigA{:,end}, blackVol{:,1});                        % matching the forecast length to IV data
        date = blackVol{ref,1};                                             % defines the date index for vol forecasts
        
        % GARCH annualized measures 
        upper = UB{ref2, index};    % 97.5th percentile GARCH sim
        mid = SigA{ref2, index};    % mean / 50th percentile
        lower = LB{ref2, index};    % 2.5th percentile GARCH sim

        iv = blackVol{ref1, index};                                         % implied volatility data       

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
        hold off; legend(h(2:end));                                         % specify the legend displays
    end
    
    outputFileName = strcat("Output/GARCH_Forecasts/Tenor", ...             % the name of the output file 
            tenors(i), "y.png"); 
    exportgraphics(fig, outputFileName);
end

addpath([root_dir filesep 'Output' filesep 'GARCH_Forecasts'])              % add the paths of GARCH forecast graphs
disp('GARCH graphs were created...');


%% Variance Risk Premia (Figure 4)


f4 = figure('visible', 'off');                 % prevent display to MATLAB 
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
    
    % plotting the vrp measures for each tenor at a term 
    plot(date, vrp{:, swap2y}, 'color', 'blue');
    plot(date, vrp{:, swap5y}, 'color', 'red'); 
    plot(date, vrp{:, swap10y}, 'color', 'green');
    
    % show the legend for the underlying series
    lgd = legend(strcat("Tenor 2Y, Term ", termsID(i)), ...
                 strcat("Tenor 5Y, Term ", termsID(i)), ...
                 strcat("Tenor 10Y, Term ", termsID(i)), ...
                 'Location', 'southwest');
    lgd.FontSize = 8;       % setting the font-size of the legend
    hold off; 
end

exportgraphics(f4, 'Output/variance_risk_premia.jpg');
disp('VRP graph was created...');


%% Autocorrelation Function for Variance Risk Premia (Figure 5)

auto = figure('visible', 'off');               % prevent display to MATLAB 
set(gcf, 'Position', [100, 100, 1050, 850]);   % setting figure dimensions

% check to see if the directory exists, if not create it
if ~exist('Output/Autocorrelations/', 'dir')
    mkdir Output/Autocorrelations/                                         
end

for n = 1:length(names)
    % plotting the autocorrelation of each VRP measure 
    autocorr(vrp{:, names(n)}, 'NumLags', 50);  
    
    outputFileName = strcat("Output/Autocorrelations/", ...
        names(n), ".jpg");                                                  % the name of the output file 
          
    exportgraphics(auto, outputFileName);
end

addpath([root_dir filesep 'Output' filesep 'Autocorrelations'])             % add the paths of autocorrelation folder
disp('Autocorrelation graphs were created...');


%% Swaption Variance Risk Premia vs VIX (Figure 6)

f6 = figure('visible', 'off');                 % prevent display to MATLAB 
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
    
    % plots the VIX index at specific maturity
    vixName = strcat("VIX", termsID(i), "Index");
    startIndex = length(vixData{:,1}) - length(date) + 1;                   % reduce the starting index of the date
    plot(date, vixData{startIndex:end, vixName}, ...                        % selecting date range to match IV measures
        'DisplayName', vixName, 'color', 'black');
    
    legend show;
    hold off; 
end

exportgraphics(f6, 'Output/vrp_vs_vix.jpg');
disp('VRP vs. VIX graphs were created...');

