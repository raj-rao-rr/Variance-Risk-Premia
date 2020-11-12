% Generates tables that relate to volatility or premium computations 

clear; 

load DATA blackVol normalVol

tenors = ["2", "5", "10"];              % tenors 2y; 5y; 10y
terms  = ["0C", "0F", "01", "02"];      % terms 3m; 6m; 12m; 24m
termsID = ["3m", "6m", "12m", "24m"];


%% (Table 1) Descriptive Statistics of Swaption Implied Volatilities 

meanV = zeros(12,1); stdV  = zeros(12,1);
kurtV = zeros(12,1); skewV = zeros(12,1);
names = ["0"; "0"; "0"; "0"; "0"; "0"; "0"; "0"; "0"; "0"; "0"; "0"];
index = 1;

for j = 1:3
    for i = 1:4
        % construct the names for each swaption tenor 
        swap  = strcat("USSV", terms(i), tenors(j), "Curncy");
      
        % filter out each corresponding swap term as an array
        swapIV = table2array(blackVol(:,swap));

        % compute descriptive statistics
        mean  = nanmean(swapIV); std   = nanstd(swapIV);
        kurt  = kurtosis(swapIV); skew  = skewness(swapIV);
        
        % assign values to each vector
        meanV(index,1) = mean;  stdV(index, 1) = std; 
        kurtV(index, 1) = kurt; skewV(index, 1) = skew;
        
        % swaption name marked term/tenor notation
        name = strcat("USSV ",termsID(i), tenors(j), 'y');
        names(index,1) = name; 
        
        index = index + 1;
    end
end

% formulate a table from the date given
descriptStat = table(names, meanV, stdV, kurtV, skewV, ...
                     'VariableNames', {'Swap Term/Tenor', 'Mean', ...
                                       'St. Dev', 'Kurtosis', 'Skewness'});

fprintf('Descriptive stats computed.\n');
writetable(descriptStat, 'Output/table1.csv');
