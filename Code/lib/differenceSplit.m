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

function [diff, eco] = differenceSplit(base, target, targetDate)

    % change in regressed values pre-post announcement 
    post = target(ismember(target{:, 1}, targetDate), :);
    pre = target(ismember(target{:, 1}, targetDate-1), :);
    
    % compute the volatility measure difference
    diff = post{:, 2:end} - pre{:, 2:end};      

    % economic filtered data matching for y date time 
    eco = base(ismember(targetDate, base{:, 1}), :);
    
end