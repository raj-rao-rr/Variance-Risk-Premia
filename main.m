% Primary executable file

clear; clc;

%% set the primary directory to work in  
root_dir = [filesep 'home' filesep 'rcerxr21' filesep 'DesiWork' ...
    filesep 'VRP'];
cd(root_dir)    % enter the root directory 

%% add paths to acess files
addpath([root_dir filesep 'Code'])
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])

% saving initialization of the main script
save 'Temp/INIT.mat' root_dir

%% running project scripts in linear order 
run('dataReader.m');
run('genTable.m');
run('volGraphs.m');
run('forecastRV.m');
run('vrpPremium.m');
run('vrpGraphs.m');
