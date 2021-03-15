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
% 
% Outputs:
%   :param: targetDates (type datetime)
%       A datetime vector representing the intersection of shared dates
%       between both two tables (base = economic varialbe) and (target =
%       regressed variable)
% 

function targetDates = matchingError(base, target)

   % annoucement data for economic measurements
   % NOTE: This should always be the first column of the economic table
   annoucements = base{:, 1};

   % find the intersection between date ranges for pre-post annoucement
   targetDates = find(ismember(target{:, 1}, annoucements));
   
end
