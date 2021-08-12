% Calculates the variance risk premium (VRP) and stores these values to a .mat file 

clearvars -except root_dir;

% loading in Swaption IV
load DATA iv

% loading in temp file for GARCH forecasts
load SigA SigA


%% Common global variables

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 12m; 24m

%% Compute the Variance Risk Premium

% matching the forecast length with IV length
date = intersect(iv{:,1}, SigA{:,1});                                       % defines the date index for vol forecasts

impVol = iv(ismember(iv{:,1}, date), :);
estVol = SigA(ismember(SigA{:,1}, date), :);

% memory allocation for variance risk premium measure (VRP)
vrp = estVol{:, 2:end} - impVol{:, 2:end};

vrp = array2table(vrp);     % convert matrix to table

%% Exporting VRP table 

vrp.Properties.VariableNames = SigA.Properties.VariableNames(2:end);
vrp.date = date; 

% move the orientation of the date column to first column position
vrp = movevars(vrp, 'date', 'Before', vrp.Properties.VariableNames{1});

save('Temp/DATA.mat', 'vrp', '-append')

fprintf('Variance Risk Premium measures have been calculated.\n');
