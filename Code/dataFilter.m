% Reducing economic calender data according to criteria 

clear; 

load INIT root_dir

% loading in economic and volatility data
load DATA ecoMap 

% loading in economic and implied volatility data
load DATA ecoData 


%% Reduce economic calender data by removing duplciates on release date

% store economic calender dates removing 
cleanEco = table();

for col = ecoMap.keys
    
    filterData = ecoData(ismember(ecoData.Event, col), :);
    
    % ---------------------------------------------------------
    % remove weird dates that repeat (data-release lag) 
    % e.g.
    %    12/04/13 | New Home Sales | Sep | 425k
    %    12/04/13 | New Home Sales | Oct | 429k
    % ---------------------------------------------------------
    [~, ind] = unique(filterData(:, 1), 'rows');
    
    duplicate_ind = setdiff(1:size(filterData, 1), ind);                     % duplicate indices
    duplicate_val = filterData{duplicate_ind, 1};                            % duplicate values
    
    % check to see if duplicates were found, if so we remove them
    if ~isnan(duplicate_ind)
        cleanEco = [cleanEco; filterData(~ismember(filterData{:, 1}, ...
            duplicate_val), :)];
    else
        cleanEco = [cleanEco; filterData];
    end
end

% sort values by datetime 
cleanEco = sortrows(cleanEco, 1);

%% Reduced economic calender data by forecast uncertainity (percentile)

% #######################
% Note our uncertainity windows are subject to subject, given percentiles 
% are subject to data provided (no hard limits)
% #######################

% store economic calender dates for high/low forecast uncertainity 
ecoSTD25 = table();
ecoSTD75 = table();

% itterate through each of the events provided
for event = ecoMap.values

    % filter data by macro economic event
    filterData = cleanEco(ismember(cleanEco.Ticker, event), :);

    % compute the top and bottom decile/quartiles forecast STD
    pct25 = quantile(filterData.StdDev, .25);
    pct75 = quantile(filterData.StdDev, .75);

    % bucket out economic figures according to std value
    ecoBin2 = filterData((filterData.StdDev <= pct25), :);
    ecoBin3 = filterData((filterData.StdDev >= pct75), :);

    % concat vertically all economic annoucments matching criteria
    ecoSTD25 = [ecoSTD25; ecoBin2];
    ecoSTD75 = [ecoSTD75; ecoBin3];

end

%% save changes to modified economic calender releases

save('Temp/FILTER', 'cleanEco', 'ecoSTD25', 'ecoSTD75')

fprintf('Data has been modifed and reduced.\n'); 
