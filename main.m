% Primary executable file

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

% saving initialization of the main script
save 'Temp/INIT.mat' root_dir

%% running project scripts in linear order 
% run('dataReader.m');
% run('genTable.m');
% run('volGraphs.m');
% run('forecastRV.m');
% run('vrpPremium.m');
% run('vrpGraphs.m');
% run('macroRegress.m');
