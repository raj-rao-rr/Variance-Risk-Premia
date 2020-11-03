% Calculates the variance risk premium (VRP) and stores these values to a .mat file 

clear; 

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol

% loading in temp file for GARCh forecasts
load SigA SigA 

%% Common global variables

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 1y; 2y

%% Compute the Variance Risk Premium

% matching the forecast length with IV length
impVol = blackVol(ismember(blackVol{:,1}, SigA{:,13}), :);
estVol = SigA(ismember(SigA{:,13}, impVol{:,1}), :);

% memory allocation for variance risk premium measure
vrp = zeros(size(impVol,1), size(impVol,2)-1);
index = 1;

for T = 1:length(tenors)
    for t = 1:length(terms)
        name = strcat("USSV", terms(t), tenors(T), "Curncy");               % determine security name

        vrp(:, index) = estVol.(name) - impVol.(name);                      % compute VRP measure and assign to matrix
        index = index + 1; 
    end 
    disp(name)
    disp(estVol.(name)); disp(impVol.(name))
end

vrp = array2table(vrp);     % convert matrix to table

% assigning new variable names to VRP table
vrp.Properties.VariableNames = SigA.Properties.VariableNames(1:end-1);
vrp.date = impVol{:, 1};

% move the orientation of the date column to first column position
vrp = movevars(vrp, 'date' ,'Before', vrp.Properties.VariableNames{1});

save Temp/VRP.mat vrp
disp('Variance Risk Premium measures have been calculated');
