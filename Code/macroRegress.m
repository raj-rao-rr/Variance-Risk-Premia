% Peform regression for macroeconomic variables and VRP 

clear; 

load INIT root_dir

% loading in economic data
load DATA ecoData keys

% loading in VRP measures
load VRP vrp


%% Regression on Macro surprises 

baseTB = zeros(size(keys, 2), 4);

% check to see if the directory exists, if not create it
if ~exist('Output/MacroRegressions/', 'dir')
    mkdir Output/MacroRegressions/                                         
end

% iterate through each vrp measure 
for index = 1:12
    vrpName = vrp.Properties.VariableNames{index+1};
    fprintf('VRP measure for %s\n', vrpName);
    
    % used to iterate through rows building table
    rows = 1;
    
    % daily changes +/- day of release of annoucnemnt 
    for i = keys

       try
           % filter out for particular economic 
           filterData = ecoData(ismember(ecoData{:, 'Ticker'}, i), :);
           
           % checking runtime of regressed values
           event = filterData{1, 'Event'}; 
           fprintf('\tRegressing on %s\n', event{:});

           % annoucement data and pre-annoucement 
           annoucements = filterData{:, 'DateTime'};

           % compute the percentage change evidenced in post/pre annoucement 
           postVRP = vrp(ismember(vrp{:, 'date'}, annoucements), :);
           preVRP = vrp(ismember(vrp{:, 'date'}, annoucements-1), :);

           % if postVRP is larger, then we scale back the size of post VRP
           targetDates = intersect(postVRP{:, 1}, preVRP{:, 1}+1);

           % percent of VRP change pre-post announcement 
           postVRP = vrp(ismember(vrp{:, 'date'}, targetDates), :);
           preVRP = vrp(ismember(vrp{:, 'date'}, targetDates-1), :);
           pct = (postVRP{:, 2:end} - preVRP{:, 2:end});

           % economic filter matching for VRP date time 
           eco = filterData(ismember(filterData{:, 'DateTime'}, ...
               targetDates), :);

% --------------------------------------------------------------------
%            % GRAPHICAL VISUALIZATION (Uncomment for plot)
%            f4 = figure('visible', 'off');                                   % prevent display to MATLAB 
%            set(gcf, 'Position', [100, 100, 1050, 650]);                     % setting figure dimensions
%            scatter(eco{:, 'Surprise'}, pct(:, 2))
%            xlabel(strcat(event + " Surprise"));
%            ylabel("VRP Change")
% --------------------------------------------------------------------

           % perform linear regression with significance
           mdl = fitlm(eco{:, 'Surprise'}, pct(:, index));

           % select model specifications for each regression 
           baseTB(rows, :) = mdl.Coefficients{2,:}; 
           rows = rows + 1;
           
       catch
           fprintf('\nError looking to split %s\n', i{:});
       end
    end
    
    % export table to .csv
    exportTB = array2table(baseTB);
    exportTB.Properties.VariableNames = {'Estimate' 'SE' 'tStat' 'pValue'};
    exportTB.Event = keys';
    
    exName = strcat('Output/MacroRegressions/', vrpName, '.csv');
    writetable(exportTB, exName);
end

addpath([root_dir filesep 'Output' filesep 'MacroRegressions'])              % add the paths of GARCH forecast graphs
