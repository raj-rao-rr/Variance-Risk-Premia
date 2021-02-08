%
% Author, Rajesh Rao
% 
% Computing the volatility difference between pre/post annoucements
% as well as the filtered economic data 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: base  (type table)
%       Economic annoucments that track a particular event
%   :param: target (type table)
%       Target variable measure to track against economic event
%   :param: targetDate (type datetime array)
%       Intersecting dates for variables vectors 
%   :param: window (type int)
%       The number of periods to lookback, e.g. 1 = 1-day
% 
% Outputs:
%   :param: diff (type matrix)
%       Returns the differnce matrix for all components of the target
%       variable, ignoring the first column of the target table
%   :param: eco (type table)
%       Returns the economic variables filtered by the target datetime
%   
%   NOTE: diff and eco variables are not subject to same lengths
% 

function [diff, eco] = differenceSplit(base, target, targetDate, window)
    
    yNames = target.Properties.VariableNames(2:end);

    % target date windows for pre-post announcement 
    post = target(ismember(target{:, 1}, targetDate), :);
    pre = target(ismember(target{:, 1}, targetDate-window), :);

    % compute the volatility measure difference and convert to table
    diff = array2table(post{:, 2:end} - pre{:, 2:end});  
    diff.DateTime = targetDate;
    diff = movevars(diff, 'DateTime', 'Before', ...
        diff.Properties.VariableNames{1});
    
    % re-assign table names accordingly
    diff.Properties.VariableNames(2:end) = yNames; 
    
    % economic filtered data matching for y date time 
    eco = base(ismember(base{:, 1}, targetDate), :);
    
end