%
% Author, Rajesh Rao
% 
% Finds the intersection between both macro economic fields and the 
% implied volatility/varaince risk premia levels provided
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: base (type table)
%       Economic annoucments that track a particular event, this is named
%       ecoData for the base case (refer to dataReader.m)
%   :param: target (type table)
%       Target variable measure to track against economic event
%   :param: window (type int)
%       The number of periods to lookback, e.g. 1 = 1-day
% 

function targetDates = matchingError(base, target, window)

   % annoucement data for economic measurements
   % NOTE: This should always be the first column of the economic table
   annoucements = base{:, 1};

   % daily changes +/- day from release of annoucnemnt 
   % annoucement date EOD price - day prior EOD price
   post = target(ismember(target{:, 1}, annoucements), :);
   pre = target(ismember(target{:, 1}, annoucements-window), :);
   
   % find the intersection between date ranges
   targetDates = intersect(post{:, 1}, pre{:, 1}+window);
   
end
