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
out_reg_dir = 'Output/macro-announcements/regressions/';

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


%% Construct term structure graphs for Term (2y, 5y, 10y)

a = readtable('regressIVCoefs.csv');
[n, ~] = size(a);

% iterate through each RHV 
for cRow = 1:2:n-3

    fig = figure('visible', 'off');  
    set(gcf, 'Position', [100, 100, 1050, 600]);

    % row containing the pValues for each coefs
    pRow = cRow + 1; 

    % filter each RHV variable to check significance
    filter2y = a(cRow:pRow, [{'Var'}, swap2y]);
    filter5y = a(cRow:pRow, [{'Var'}, swap5y]);
    filter10y = a(cRow:pRow, [{'Var'}, swap10y]);

    rhv = filter2y{1, 'Var'};           % name of RHV
    threshold = 0.1;                    % p-value threshold
    
    % conditional filters for each tenor
    cond2y = filter2y{2, swap2y} <= threshold;  
    cond5y = filter5y{2, swap5y} <= threshold; 
    cond10y = filter10y{2, swap10y} <= threshold; 

    % if all component parts are signfiiciant, then we return
    % there are 4 elements within each term structure
    if sum(cond2y) == 4 || sum(cond5y) == 4 || sum(cond10y) == 4
        hold on
        plot(filter2y{1, swap2y}, 'DisplayName', '2y Term', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        plot(filter5y{1, swap5y}, 'DisplayName', '5y Term', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        plot(filter10y{1, swap10y}, 'DisplayName', '10y Term', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        
        title({strcat("Swaption Implied Volatility Response to ", rhv{:}), ...
        '(estimates where p-value < 0.10)'})
        xticks(1:4)
        xticklabels({'3m', '6m', '12m', '24m'})
        xlabel('Tenor (in months)')
        ylabel('Regression Estimates (coefs)')
        hold off
        legend show

        % export figure to correct directory
        exName = strcat(out_tms_dir, "iv/", rhv{:}, " (term).jpg");
        exportgraphics(fig, exName{:});
    end  
end

%% Construct term structure graphs for Tenor (3m, 6m, 12m, 24m)

a = readtable('regressIVCoefs.csv');
[n, ~] = size(a);

% iterate through each RHV 
for cRow = 1:2:n-3

    fig = figure('visible', 'off');  
    set(gcf, 'Position', [100, 100, 1050, 600]);

    % row containing the pValues for each coefs
    pRow = cRow + 1; 

    % filter each RHV variable to check significance
    filter3m = a(cRow:pRow, [{'Var'}, swap3m]);
    filter6m = a(cRow:pRow, [{'Var'}, swap6m]);
    filter12m = a(cRow:pRow, [{'Var'}, swap12m]);
    filter24m = a(cRow:pRow, [{'Var'}, swap24m]);

    rhv = filter3m{1, 'Var'};           % name of RHV
    threshold = 0.1;                    % p-value threshold
    
    % conditional filters for each tenor
    cond3m = filter3m{2, swap3m} <= threshold;  
    cond6m = filter6m{2, swap6m} <= threshold; 
    cond12m = filter12m{2, swap12m} <= threshold; 
    cond24m = filter24m{2, swap24m} <= threshold; 
    
    % if all component parts are signfiiciant, then we return
    % there are 4 elements within each term structure
    if sum(cond3m) == 3 || sum(cond6m) == 3 || sum(cond12m) == 3 || sum(cond24m) == 3
        hold on
        plot(filter3m{1, swap3m}, 'DisplayName', '3m Tenor', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        plot(filter6m{1, swap6m}, 'DisplayName', '6m Tenor', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        plot(filter12m{1, swap12m}, 'DisplayName', '12m Tenor', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        plot(filter24m{1, swap24m}, 'DisplayName', '24m Tenor', 'LineWidth', 1, ...
            'LineStyle', '-', 'Marker', 's')
        
        title({strcat("Swaption Implied Volatility Response to ", rhv{:}), ...
        '(estimates where p-value < 0.10)'})
        xticks(1:4)
        xticklabels({'2y', '5y', '10y'})
        xlabel('Term (in months)')
        ylabel('Regression Estimates (coefs)')
        hold off
        legend show

        % export figure to correct directory
        exName = strcat(out_tms_dir, "iv/", rhv{:}, " (tenor).jpg");
        exportgraphics(fig, exName{:});
    end
end

%%

fprintf('Term structure graph for macro-annoucement estimates created.\n')