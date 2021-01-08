% Calculates the variance risk premium (VRP) and stores these values to a .mat file 

clear; 

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol

% loading in temp file for GARCh forecasts
load SigA SigA LB UB

%% Common global variables

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 12m; 24m

%% Compute the Variance Risk Premium

% matching the forecast length with IV length
impVol = blackVol(ismember(blackVol{:,1}, SigA{:,1}), :);
estVol = SigA(ismember(SigA{:,1}, impVol{:,1}), :);

% dimensions for volatility, used for VRP construction
[n, m] = size(impVol);

% memory allocation for variance risk premium measure (VRP)
vrp = zeros(n, m-1);

index = 1;

for T = 1:length(tenors)        % itterate through tenors 2y, 5y, 10y
    
    for t = 1:length(terms)     % itterate through terms 4m, 6m, 12m, 24m
        % create security name
        name = strcat("USSV", terms(t), tenors(T), "Curncy");               
        
        % compute VRP measure and assign to matrix
        vrp(:, index) = estVol.(name) - impVol.(name);                      
        index = index + 1; 
        
    end 
    
end

vrp = array2table(vrp);     % convert matrix to table

%% Exporting VRP table 

vrp.Properties.VariableNames = SigA.Properties.VariableNames(2:end);
vrp.date = impVol{:, 1}; 

% move the orientation of the date column to first column position
vrp = movevars(vrp, 'date', 'Before', vrp.Properties.VariableNames{1});

save Temp/VRP.mat vrp

fprintf('Variance Risk Premium measures have been calculated.\n');
