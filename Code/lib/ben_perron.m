% Structural breaks as detailed in the Bai and Perron (1998, 2003a,b) paper

% loading in temp file for Swap IV, Treasury data, VIX data
load DATA blackVol normalVol treasuryData vixData

%%

fig = figure('visible', 'on');                                              % prevent display to MATLAB
set(gcf, 'Position', [100, 100, 1250, 900]);                                % setting figure dimensions
    

hold on;
plot(blackVol{:, 1}, blackVol{:, 2})

X = [1:1:length(blackVol{:, 2})]';
X = [ones(length(X), 1) X];
[b, bint, r] = regress(blackVol{:, 2}, X);

plot(blackVol{:, 1}, b(1)+X(:,2)*b(2))

%%% Computing splits from the given set

n = length(blackVol{:, 2});                  % size of data set
rollT = ceil(n/10);                          % rolling window of obs.

% itterate through outer scope
for t = 1:rollT:n-rollT
    
    miniVal= power(10,10);                     % minimum difference 
    miniDate = datetime(2000,1,1);             % minimum date 
    
    % itterate through t-alpha term within interval
    for t_alpha = t:t+rollT
        
        % SSR (sum of squared residuals) over an interval
        w1 = sum(r(t:t_alpha) .^ 2);                  % rolling window 1                    
        w2 = sum(r(t_alpha:t+rollT) .^ 2);            % [1, Ta]-[Ta, T]

        % check percentage change over interval
        change = w1 - w2;     
        
        % checking for the smallest absolute change in break
        if abs(change) < abs(miniVal)
            miniVal = change; miniDate = blackVol{t_alpha, 1};
        end
    end
    
    disp(miniDate)
    % plotting the break even points
    scatter(blackVol{blackVol{:,1} == miniDate, 1}, ...
        blackVol{blackVol{:,1} == miniDate, 2}, 30, 'r', 'filled');
 end

hold off;