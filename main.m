% Primary executable file (run all file)

clear; clc;

%% set the primary working directory
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files by naming convention 

addpath([root_dir filesep 'Code'])
addpath([root_dir filesep 'Code/lib'])                                      
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])
addpath([root_dir filesep 'Output' filesep 'autocorrelations'])  
addpath([root_dir filesep 'Output' filesep 'garch-forecasts']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements'])  
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'regressions'])  
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'responses'])  
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'buckets']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'buckets' filesep 'iv']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'buckets' filesep 'rv']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'buckets' filesep 'vrp']) 
 
%% running project scripts in synchronous order

tic
run('dataReader.m');            % read in data from source
run('volGraphs.m');             % produce preliminary vol graphs
run('forecastRV.m');            % forecast realized volatility
run('vrpCalculation.m');        % compute the variance risk premia    
run('vrpGraphs.m');             % produce graphs that use VRP measurements
run('macroBucket.m');           % produce bar graphs for macro-responses
run('macroRegress.m');          % perform regression on macro-surprises    
run('macroAggregate.m');        % examine reponse function to macro-surprises    
toc
