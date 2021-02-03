% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files
addpath([root_dir filesep 'Code'])
addpath([root_dir filesep 'Code/lib'])                                      % library of additonal functions
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])
addpath([root_dir filesep 'Output' filesep 'autocorrelations'])  
addpath([root_dir filesep 'Output' filesep 'garch-forecasts']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements'])  
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'regressions'])  
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'std-buckets']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'std-buckets' filesep 'iv']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'std-buckets' filesep 'rv']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'std-buckets' filesep 'vrp']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'term-structure']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'term-structure' filesep 'iv']) 
addpath([root_dir filesep 'Output' filesep 'macro-announcements' filesep ...
    'term-structure' filesep 'vrp']) 
 
% saving initialization of the main script
save 'Temp/INIT.mat' root_dir

%% running project scripts in linear order 
run('dataReader.m');        % often fails on first run, simply run again
run('dataFilter.m');
run('volGraphs.m');
% run('forecastRV.m');
run('vrpCalculation.m');
run('vrpGraphs.m');
run('macroRegress.m');
run('macroStd.m');
run('macroTermStruct.m');
