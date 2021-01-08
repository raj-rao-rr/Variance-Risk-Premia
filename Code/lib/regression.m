%
% Author, Rajesh Rao
% 
% Peforms a regression on varaibles 'X', 'y'. Where 'X' is a table of 
% economic data releases provided by Bloomberg and y is the measured 
% target. These targets include our measure for variance risk premia, 
% implied volatility and realized volatiltity 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: X (type table) 
%       The economic surprises from Bloomberg to regress on 
%   :param: y (type table) 
%       The volatility measures (include IV, RV and VRP)
%   :param: col (type str) 
%       The column from the economic surprises, to regress on 
%       e.g. "SurpriseZscore", "Surprises"


function tb = regression(X, y, col, map)

    % all availabe macro events
    keys = unique(X{:, 'Ticker'})';
    
    [~, n] = size(y.Properties.VariableNames);
    [~, k] = size(keys);
    
    % initialize the columns that will be exported for regressed figures
    Coefs = zeros((n-1)*k, 1);          % regression coefficents
    StdErr = zeros((n-1)*k, 1);         % standard error of regression
    pValue = zeros((n-1)*k, 1);         % p-value calculation
    tStat = zeros((n-1)*k, 1);          % t-statistic
    R2 = zeros((n-1)*k, 1);             % R-squared measure
    adjR2 = zeros((n-1)*k, 1);          % Adjusted R-squared
    Event = cell((n-1)*k, 1);           % economic event considered
    Security = cell((n-1)*k, 1);        % security name considered
    RegressVar = cell((n-1)*k, 1);      % RHS variable
    nObs = zeros((n-1)*k, 1);           % number of observations
   
    % used to iterate through rows building table
    rows = 1;
    
    % iterate through each columns of y, assuming first column is date
    for index = 1:n-1
        names = y.Properties.VariableNames{index+1};
        fprintf('Measure for %s\n', names);

        % iterate through each of the key annoucement events
        for i = keys

               % filter out for particular economic event
               filterData = X(ismember(X{:, 'Ticker'}, i), :);
               
               % checking runtime of regressed values
               event = filterData{1, 'Event'}; 
               fprintf('\tRegressing on %s\n', event{:});
               
               % find the intersection between date ranges
               targetDates = matchingError(filterData, y, 1);
               
               % computes difference and economic surprise
               [diff, eco] = differenceSplit(filterData, y, targetDates);
               
               % perform linear regression with significance
               [est,sd_err,R2v,R2vadj,errv,~,F] = olsgmm(diff(:, index), ...
                   eco{:, col}, 0, 1);
               
               % assigning the correct statistic to corresponding column 
               Coefs(rows, 1) = est;
               StdErr(rows, 1) = sd_err;
               pValue(rows, 1) = F(3);
               tStat(rows, 1) = est/sd_err;
               R2(rows, 1) = R2v;
               adjR2(rows, 1) = R2vadj;
               Event(rows, 1) = {map(i{:})};
               Security(rows, 1) = {names};
               RegressVar(rows, 1) = {col};
               nObs(rows, 1) = size(errv, 1);
               
               % iteratively moving down the rows
               rows = rows + 1;
        end
        
    end
    
    tb = table(Coefs, StdErr, pValue, tStat, R2, adjR2, Event, ...
        Security, RegressVar, nObs);
    
end
