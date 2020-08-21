% Reads in the provided data files from Input and stores these variables to a .mat file

clear;  

%% Date Reading and Cleaning

% read in data from .csv file as a table   
blackVol = readtable('swapBlackIV.csv');        % N by 13 matrix
normalVol = readtable('swapNormalIV.csv');        % N by 13 matrix

treasuryData = readtable('10yRate');            % N by 2 matrix
swapData = readtable('swapRates.csv');          % N by 7 matrix
vixData = readtable('VIX.csv');                 % N by 2 matrix

% remove all NaN rows from the tables
blackVol = rmmissing(blackVol);        
normalVol = rmmissing(normalVol);        
treasuryData = rmmissing(treasuryData); 
swapData = rmmissing(swapData);  

% swap maturities: 1y; 2y; 3y; 5y; 7y; 10y;
swapRates = swapData(:,2:end).Properties.VariableDescriptions;   

% save all variables in *.mat file to be referenced
save('Temp/DATA', 'blackVol',  'normalVol' , 'treasuryData', 'swapData', ...
     'vixData', 'swapRates')
 
disp('Data has been downloaded...'); 