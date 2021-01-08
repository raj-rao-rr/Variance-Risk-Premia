% Peform regression on macroeconomic variables 

clear; 

load INIT root_dir

% loading in economic and volatility data
load DATA yeildCurve ecoMap ecoData keys blackVol econVars lowIR highIR
load FILTER ecoSTD10 ecoSTD25 ecoSTD75 ecoSTD90 impvolTermReduced ...
    impvolTenorReduced
load SigA SigA 

% loading in VRP measures
load VRP vrp


%% Initialization of variables and directories

% check to see if the following directories exists, if not create them
if ~exist('Output/MacroRegressions/', 'dir')
    mkdir Output/MacroRegressions/                                         
end

if ~exist('Output/MacroRegressions/Regressions/', 'dir')
    mkdir Output/MacroRegressions/Regressions/  
    
    % create directory for term structure graphs for full series
    mkdir Output/MacroRegressions/Regressions/full/
    
    mkdir Output/MacroRegressions/Regressions/full/vrp/ 
    mkdir Output/MacroRegressions/Regressions/full/iv/
    mkdir Output/MacroRegressions/Regressions/full/rv/
    
    % create directory for term structure graphs for partial series
    mkdir Output/MacroRegressions/Regressions/partial/
    
    mkdir Output/MacroRegressions/Regressions/partial/vrp/ 
    mkdir Output/MacroRegressions/Regressions/partial/vrp/high/
    mkdir Output/MacroRegressions/Regressions/partial/vrp/low/
    
    mkdir Output/MacroRegressions/Regressions/partial/iv/
    mkdir Output/MacroRegressions/Regressions/partial/iv/high/
    mkdir Output/MacroRegressions/Regressions/partial/iv/low/
    
    mkdir Output/MacroRegressions/Regressions/partial/rv/
    mkdir Output/MacroRegressions/Regressions/partial/rv/high/
    mkdir Output/MacroRegressions/Regressions/partial/rv/low/
end

if ~exist('Output/MacroRegressions/StdBuckets/', 'dir')
    mkdir Output/MacroRegressions/StdBuckets/  
    
    % create directory to store standard deviation buckets 
    mkdir Output/MacroRegressions/StdBuckets/vrp/ 
    mkdir Output/MacroRegressions/StdBuckets/iv/
    mkdir Output/MacroRegressions/StdBuckets/rv/ 
end

if ~exist('Output/MacroRegressions/TermStructure/', 'dir')
    mkdir Output/MacroRegressions/TermStructure/  
    
    % create directory to store standard deviation buckets 
    mkdir Output/MacroRegressions/TermStructure/vrp/ 
    mkdir Output/MacroRegressions/TermStructure/iv/
end

addpath([root_dir filesep 'Output' filesep 'MacroRegressions'])             

%% interest rate regimes according to fed funds rate

irEnv = {lowIR, highIR};
rateNames = {'Low Interest', 'High Interest'};
regimes = {'low', 'high'}; 

volData = {vrp, blackVol, SigA};
volFolder = {'vrp', 'iv', 'rv'};
volNames = {'Variance Risk Premium', 'Implied Volatility', ...
    'Realized Volatility'};

regressVar = 'SurpriseZscore';

%% Regression on Macro surprises over full economic horizon 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
       
    % perform regression on bucket economic releases
    regTB = regression(ecoData, volData{data}, regressVar, ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs.csv');
    
    % write regression coeffcients to table
    writetable(regTB, name);

end

%% Regression on interest rates over partial economic horizon 

outDirectory = 'Output/MacroRegressions/Regressions/partial';

% iterate through each interest rate regime {'low', 'high'}
for index = 1:2

    % selects the interest rate environment 
    rateDf = irEnv{:, index};

    % filter economic dates according to interest rate regime 
    filterEco = ecoData(ismember(ecoData{:, 1}, rateDf{:, 1}), :);

    % perform regression on bucket economic releases
    regTB = regression(filterEco, yeildCurve, regressVar, ecoMap);
    name = strcat(outDirectory,'/',regimes{index},'RegressPCACoefYeilds.csv');

    % write regression coeffcients to table
    writetable(regTB, name);
end

%% Regression on interest rates over partial economic horizon wt uncertainity buckets

outDirectory = 'Output/MacroRegressions/Regressions/partial';

% iterate through each interest rate regime {'low', 'high'}
for index = 1:2

    % selects the interest rate environment 
    rateDf = irEnv{:, index};

    % filter economic dates according to interest rate regime and bucket 
    filterEco1 = ecoSTD25(ismember(ecoSTD25{:, 1}, rateDf{:, 1}), :);
    filterEco2 = ecoSTD75(ismember(ecoSTD75{:, 1}, rateDf{:, 1}), :);

    % perform regression on bucket economic releases
    regTB1 = regression(filterEco1, yeildCurve, regressVar, ecoMap);
    regTB2 = regression(filterEco2, yeildCurve, regressVar, ecoMap);
    
    name1 = strcat(outDirectory,'/',regimes{index},'RegressPCACoefYeilds25.csv');
    name2 = strcat(outDirectory,'/',regimes{index},'RegressPCACoefYeilds75.csv');
    
    % write regression coeffcients to table
    writetable(regTB1, name1); 
    writetable(regTB2, name2);
end

%% Regression on Macro surprises over partial economic horizons

outDirectory = 'Output/MacroRegressions/Regressions/partial';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
    
    % iterate through each interest rate regime {'low', 'high'}
    for index = 1:2
        
        % selects the interest rate environment 
        rateDf = irEnv{:, index};

        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 1}, rateDf{:, 1}), :);
        
        % perform regression on bucket economic releases
        regTB = regression(filterEco, volData{data}, regressVar, ecoMap);
        name = strcat(outDirectory, '/', volFolder{data}, '/', ...
            regimes{index}, '/regressCoefs.csv');
        
        % write regression coeffcients to table
        writetable(regTB, name);
    end
    
end

%% Regression on interest rates over partial economic horizon 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB = regression(ecoData, yeildCurve, regressVar, ecoMap);
name = strcat(outDirectory, '/', 'regressCoefsYeilds.csv');

% write regression coeffcients to table
writetable(regTB, name);

%% Regression on Macro surprises over standard deviation buckets 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
    
    % perform regression on bucket economic releases
    regTB = regression(ecoSTD10, volData{data}, regressVar, ...
        ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs10bucket.csv');
    writetable(regTB, name);

    regTB = regression(ecoSTD25, volData{data}, regressVar, ...
        ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs25bucket.csv');
    writetable(regTB, name);

    regTB = regression(ecoSTD75, volData{data}, regressVar, ...
        ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs75bucket.csv');
    writetable(regTB, name);
   
    regTB = regression(ecoSTD90, volData{data}, regressVar, ...
        ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressCoefs90bucket.csv');
    writetable(regTB, name)
    
end

%% Regression on Interest rates over standard deviation buckets 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB = regression(ecoSTD10, yeildCurve, regressVar, ecoMap);
name = strcat(outDirectory, '/', 'regressCoefsYeilds10.csv');
writetable(regTB, name);

regTB = regression(ecoSTD25, yeildCurve, regressVar, ecoMap);
name = strcat(outDirectory, '/', 'regressCoefsYeilds25.csv');
writetable(regTB, name)

regTB = regression(ecoSTD75, yeildCurve, regressVar, ecoMap);
name = strcat(outDirectory, '/', 'regressCoefsYeilds75.csv');
writetable(regTB, name)

regTB = regression(ecoSTD90, yeildCurve, regressVar, ecoMap);
name = strcat(outDirectory, '/', 'regressCoefsYeilds90.csv');
writetable(regTB, name)

%% Implied Volatility changes across event horizon 

fig = figure('visible', 'off');                 
set(gcf, 'Position', [100, 100, 1100, 600]);   

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',8)

% allocate memory for low and high interest rate regime 
ivIR = zeros(10, 2);

% iterate through economic variables
for i = 1:10
    
    % iterate through interest rate regime
    for index = 1:2
        
        % selects the interest rate environment 
        df = irEnv{:, index};
        
        % filter economic dates according to interest rate regime 
        filterEco = ecoData(ismember(ecoData{:, 1}, df{:, 1}), :);
        
        event = keys(i);    % economic event  
        
        % filter data by macro economic event
        filterData = filterEco(ismember(filterEco{:, 'Ticker'}, event), :);

        % compute the top and bottom decile/quartiles forecast STD per event
        bottom10 = quantile(filterData.StdDev, .10);
        bottom25 = quantile(filterData.StdDev, .25);
        top25 = quantile(filterData.StdDev, .75);
        top10 = quantile(filterData.StdDev, .90);
        
        % bucket out economic figures according to std value
        ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
        ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
        ecoBin3 = filterData((filterData.StdDev >= top25), :);
        ecoBin4 = filterData((filterData.StdDev >= top10), :);

        % match target dates for each STD period 
        datesBin1 = matchingError(ecoBin1, blackVol, 1);
        datesBin2 = matchingError(ecoBin2, blackVol, 1);
        datesBin3 = matchingError(ecoBin3, blackVol, 1);
        datesBin4 = matchingError(ecoBin4, blackVol, 1);

        % change in regressed values pre-post announcement 
        [diffBin1, ~] = differenceSplit(ecoBin1, blackVol, datesBin1);
        [diffBin2, ~] = differenceSplit(ecoBin2, blackVol, datesBin2);
        [diffBin3, ~] = differenceSplit(ecoBin3, blackVol, datesBin3);
        [diffBin4, ~] = differenceSplit(ecoBin4, blackVol, datesBin4);

        % building out the average difference cell per STD period
        % function computes the mean, column wise (per each security) 
        y = [mean(mean(diffBin1(:, :), 'omitnan')), ...
            mean(mean(diffBin2(:, :), 'omitnan')), ...
            mean(mean(diffBin3(:, :), 'omitnan')), ...
            mean(mean(diffBin4(:, :), 'omitnan'))];

        % scaler representing average VRP change across time and bucket
        simpleAvg = mean(y, 'omitnan'); 
                                                             
        ivIR(i, index) = simpleAvg;
        
    end
    
end

% compute confidence intervals for both low/high rate regimes (90%)
confidence = bootci(2000, {@mean, ivIR}, 'alpha', 0.10);

hold on; 
% plottin the long run average and time series of VRP per rate regime 
h(1,1) = scatter((1:10)', ivIR(:, 1), 'cyan', 'd', 'filled', ...
    'DisplayName', 'Low Rate Regime', 'MarkerEdgeColor', 'black');
h(2,1) = plot(zeros(10, 1)+mean(ivIR(:, 1)), 'DisplayName', ...
    'Low Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'cyan');
h(3,1) = plot(zeros(10, 1)+confidence(1, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'cyan');

h(4,1) = scatter((1:10)', ivIR(:, 2), 'magenta', 's', 'filled', ...
    'DisplayName', 'High Rate Regime', 'MarkerEdgeColor', 'black');
h(5,1) = plot(zeros(10, 1)+mean(ivIR(:, 2)), 'DisplayName', ...
    'High Rate Avg.', 'LineStyle', '-', 'LineWidth', 2, 'color', 'magenta');
h(6,1) = plot(zeros(10, 1)+confidence(1, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'magenta');

h(7,1) = plot(zeros(10, 1)+confidence(2, 1), 'DisplayName', ...
    '90% Confidence (Low Rate)', 'LineStyle', '--', 'color', 'cyan');
h(8,1) = plot(zeros(10, 1)+confidence(2, 2), 'DisplayName', ...
    '90% Confidence (High Rate)', 'LineStyle', '--', 'color', 'magenta');

xticks(1:10); xticklabels(econVars); xtickangle(30);
title({'Implied Volatility Responsivness to Economic Annoucments', ...
    'Responses are taken at STD percentiles (0.10, 0.25, 0.75, 0.90)'});
ylabel("Average Implied Volatility Change by STD Bucket", 'FontSize', 8);
legend(h(1:6))

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/avgIV.jpg");
exportgraphics(fig, name);

%% T-distribution - Performing regression on reduced economic figures 

fig = figure('visible', 'off');  
set(gcf, 'Position', [100, 100, 1250, 600]);
rng('default')  % For reproducibility

event = 'CONSSENT Index';
filterData1 = ecoSTD25(strcmp(ecoSTD25.Ticker, event), :);
filterData2 = ecoSTD75(strcmp(ecoSTD75.Ticker, event), :);

% match target dates for each STD period 
targetDate1 = matchingError(filterData1, blackVol, 1);
targetDate2 = matchingError(filterData2, blackVol, 1);

% change in regressed values pre-post announcement 
[diff1, eco1] = differenceSplit(filterData1, blackVol, targetDate1);
[diff2, eco2] = differenceSplit(filterData2, blackVol, targetDate2);

% compute the pre/post filter difference vector
diff1Vector = mean(diff1, 2);
diff2Vector = mean(diff2, 2);

% perform regression on Z-scores to determine efficacy
[bv1,~,~,~,~,~,F1] = olsgmm(diff1Vector, eco1.SurpriseZscore, 0, 1);
[bv2,~,~,~,~,~,F2] = olsgmm(diff2Vector, eco2.SurpriseZscore, 0, 1);

SEM = std(diff1Vector)/sqrt(4);                     % Standard Error
ts = tinv([0.005  0.995], 3);                       % T-Score 99% Con 3-df
ci = mean(diff1Vector) + ts*SEM;                    % Confidence Intervals

[bv3,~,~,~,~,~,F3] = olsgmm(diff1Vector((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), eco1.SurpriseZscore((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), 0, 1);

% compute a scatter histogram for the average change in vol measure
subplot(1, 2, 1); hold on; 
scatter(eco1.SurpriseZscore, diff1Vector, 'MarkerFaceColor', 'blue', ...
    'MarkerEdgeColor', 'black', 'DisplayName', 'Raw Data'); 
scatter(eco1.SurpriseZscore((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), diff1Vector((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), 'MarkerFaceColor', 'red', ...
    'MarkerEdgeColor', 'black', 'MarkerFaceAlpha',1, 'DisplayName', ...
    'T-dist 99%, 3-df'); 

plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv1, 'LineStyle', '--', ...
    'color', 'blue', 'DisplayName', ...
    strcat("\beta=", string(round(bv1, 3)), ", pValue=", ...
    string(round(F1(3), 2))))
plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv3, 'LineStyle', '--', ...
    'color', 'red', 'DisplayName', ...
    strcat("\beta=", string(round(bv3, 3)), ", pValue=", ...
    string(round(F3(3), 2))))

xlabel(strcat("Economic Surprise Z-score"), 'fontsize', 9)
ylabel(["Change in Implied Volatility", "Low Uncertainty"], 'fontsize', 9)
legend('show')

% ======================================================================

SEM = std(diff2Vector)/sqrt(4);                     % Standard Error
ts = tinv([0.005  0.995], 3);                       % T-Score 99% Con 3-df
ci = mean(diff2Vector) + ts*SEM;                    % Confidence Intervals

[bv4,~,~,~,~,~,F4] = olsgmm(diff2Vector((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), eco2.SurpriseZscore((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), 0, 1);

subplot(1, 2, 2); hold on; 
scatter(eco2.SurpriseZscore, diff2Vector, 'MarkerFaceColor', 'blue', ...
    'MarkerEdgeColor', 'black', 'DisplayName', 'Raw Data')
scatter(eco1.SurpriseZscore((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), diff2Vector((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), 'MarkerFaceColor', 'red', ...
    'MarkerEdgeColor', 'black', 'MarkerFaceAlpha',1, 'DisplayName', ...
    'T-dist 99%, 3-df');

plot(eco2.SurpriseZscore, eco2.SurpriseZscore*bv2, 'LineStyle', '--', ...
    'color', 'blue', 'DisplayName', ...
    strcat("\beta=", string(round(bv2, 3)), ", pValue=", ...
    string(round(F2(3), 2))))
plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv4, 'LineStyle', '--', ...
    'color', 'red', 'DisplayName', ...
    strcat("\beta=", string(round(bv4, 3)), ", pValue=", ...
    string(round(F4(3), 2))))

xlabel(strcat("Economic Surprise Z-score"), 'fontsize', 9)
ylabel(["Change in Implied Volatility", "High Uncertainty"], 'fontsize', 9)
legend('show')

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/tdistRegression.jpg");
exportgraphics(fig, name);

%% Normal-distribution - Performing regression on reduced economic figures 

fig = figure('visible', 'off');  
set(gcf, 'Position', [100, 100, 1250, 600]);
rng('default')  % For reproducibility

event = 'CONSSENT Index';
filterData1 = ecoSTD25(strcmp(ecoSTD25.Ticker, event), :);
filterData2 = ecoSTD75(strcmp(ecoSTD75.Ticker, event), :);

% match target dates for each STD period 
targetDate1 = matchingError(filterData1, blackVol, 1);
targetDate2 = matchingError(filterData2, blackVol, 1);

% change in regressed values pre-post announcement 
[diff1, eco1] = differenceSplit(filterData1, blackVol, targetDate1);
[diff2, eco2] = differenceSplit(filterData2, blackVol, targetDate2);

% compute the pre/post filter difference vector
diff1Vector = mean(diff1, 2);
diff2Vector = mean(diff2, 2);

% perform regression on Z-scores to determine efficacy
[bv1,~,R2v1,~,~,~,F1] = olsgmm(diff1Vector, eco1.SurpriseZscore, 0, 1);
[bv2,~,R2v2,~,~,~,F2] = olsgmm(diff2Vector, eco2.SurpriseZscore, 0, 1);

pd = fitdist(diff1Vector, 'Normal');         % fit normal distribution  
ci = paramci(pd, 'Alpha', .01);              % 99% confidence interval 

[bv3,~,R2v3,~,~,~,F3] = olsgmm(diff1Vector((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), eco1.SurpriseZscore((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), 0, 1);

% compute a scatter histogram for the average change in vol measure
subplot(1, 2, 1); hold on; 
scatter(eco1.SurpriseZscore, diff1Vector, 'MarkerFaceColor', 'blue', ...
    'MarkerEdgeColor', 'black', 'DisplayName', 'Raw Data'); 
scatter(eco1.SurpriseZscore((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), diff1Vector((diff1Vector >= ci(1)) & ...
    (diff1Vector <= ci(2))), 'MarkerFaceColor', 'red', ...
    'MarkerEdgeColor', 'black', 'MarkerFaceAlpha',1, 'DisplayName', ...
    'Normal-dist 99%'); 

plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv1, 'LineStyle', '--', ...
    'color', 'blue', 'DisplayName', ...
    strcat("\beta=", string(round(bv1, 3)), ", pValue=", ...
    string(round(F1(3), 2))))
plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv3, 'LineStyle', '--', ...
    'color', 'red', 'DisplayName', ...
    strcat("\beta=", string(round(bv3, 3)), ", pValue=", ...
    string(round(F3(3), 2))))

xlabel(strcat("Economic Surprise Z-score"), 'fontsize', 9)
ylabel(["Change in Implied Volatility", "Low Uncertainty"], 'fontsize', 9)
legend('show')

% ======================================================================

pd = fitdist(diff2Vector, 'Normal');        % fit normal distribution  
ci = paramci(pd, 'Alpha', .01);             % 99% confidence interval 

[bv4,~,R2v4,~,~,~,F4] = olsgmm(diff2Vector((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), eco2.SurpriseZscore((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), 0, 1);

subplot(1, 2, 2); hold on; 
scatter(eco2.SurpriseZscore, diff2Vector, 'MarkerFaceColor', 'blue', ...
    'MarkerEdgeColor', 'black', 'DisplayName', 'Raw Data')
scatter(eco1.SurpriseZscore((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), diff2Vector((diff2Vector >= ci(1)) & ...
    (diff2Vector <= ci(2))), 'MarkerFaceColor', 'red', ...
    'MarkerEdgeColor', 'black', 'MarkerFaceAlpha',1, 'DisplayName', ...
    'Normal-dist 99%');

plot(eco2.SurpriseZscore, eco2.SurpriseZscore*bv2, 'LineStyle', '--', ...
    'color', 'blue', 'DisplayName', ...
    strcat("\beta=", string(round(bv2, 3)), ", pValue=", ...
    string(round(F2(3), 2))))
plot(eco1.SurpriseZscore, eco1.SurpriseZscore*bv4, 'LineStyle', '--', ...
    'color', 'red', 'DisplayName', ...
    strcat("\beta=", string(round(bv4, 3)), ", pValue=", ...
    string(round(F4(3), 2))))

xlabel(strcat("Economic Surprise Z-score"), 'fontsize', 9)
ylabel(["Change in Implied Volatility", "High Uncertainty"], 'fontsize', 9)
legend('show')

% export the image to Interest Bucket for VRP measures
name = strcat("Output/MacroRegressions/ndistRegression.jpg");
exportgraphics(fig, name);

%% Construct term structure variant (refer to TermStructure/ folder)

% iterate through various volatility measures
for data = 1:2
    
    % volatility data being examined
    vol = volData{data};
    volName = volFolder(data);
    
    for event = keys
        fig = figure('visible', 'off');  
        set(gcf, 'Position', [100, 100, 1250, 600]);

        name = event{:};
        eventName = ecoMap(name); period = 1;

        % filter economic dates according to interest rate regime 
        filterLowEco = ecoData(ismember(ecoData{:, 1}, lowIR{:, 1}), :);
        filterHighEco = ecoData(ismember(ecoData{:, 1}, highIR{:, 1}), :);

        % filter economic data according to appropriate event
        filterLowData=filterLowEco(strcmp(filterLowEco.Ticker,event), :);
        filterHighData=filterHighEco(strcmp(filterHighEco.Ticker,event),:);

        % match target dates according to the date prior examined
        targetLowDate = matchingError(filterLowData, vol, period);
        targeHighDate = matchingError(filterHighData, vol, period);

        % select dates of pre/post annoucment window for vol measures
        afterLowAnnouce = vol(ismember(vol{:, 1}, ...
            targetLowDate), :);
        beforeLowAnnouce = vol(ismember(vol{:, 1}, ...
            targetLowDate-period), :);

        afterHighAnnouce = vol(ismember(vol{:, 1}, ...
            targeHighDate), :);
        beforeHighAnnouce = vol(ismember(vol{:, 1}, ...
            targeHighDate-period), :);

        % reshape for easy plotting in environment
        afterLowValues = reshape(mean(afterLowAnnouce{:, 2:end}),4,3);
        beforeLowValues = reshape(mean(beforeLowAnnouce{:, 2:end}),4,3);

        afterHighValues = reshape(mean(afterHighAnnouce{:, 2:end}),4,3);
        beforeHighValues = reshape(mean(beforeHighAnnouce{:, 2:end}),4,3);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % low interest rate enviornment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(1,2,1); hold on;
        
        plot(afterLowValues(:, 1), 'LineStyle', '--', 'color', 'red', ...
            'Marker', 'd', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (post Ann.)');
        plot(beforeLowValues(:, 1), 'LineStyle', '-', 'color', 'red', ...
            'Marker', 's', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (pre Ann.)');

        plot(afterLowValues(:, 2), 'LineStyle', '--', 'color', 'blue', ...
            'Marker', 'd', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (post Ann.)');
        plot(beforeLowValues(:, 2), 'LineStyle', '-', 'color', 'blue', ...
            'Marker', 's', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (pre Ann.)');

        plot(afterLowValues(:, 3), 'LineStyle', '--', 'color', 'green', ...
            'Marker', 'd', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (post Ann.)');
        plot(beforeLowValues(:, 3), 'LineStyle', '-', 'color', 'green', ...
            'Marker', 's', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (pre Ann.)');

        xticks(1:4); xticklabels({'3m', '6m', '12m', '24m'});
        ylabel('Variance Risk Premium');
        title({'Low Interest Rate Regime', name})
        legend('show', 'Location', 'northwest', 'fontsize', 8);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % high interest rate enviornment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(1,2,2); hold on;

        plot(afterHighValues(:, 1), 'LineStyle', '--', 'color', 'red', ...
            'Marker', 'd', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (post Ann.)');
        plot(beforeHighValues(:, 1), 'LineStyle', '-', 'color', 'red', ...
            'Marker', 's', 'MarkerFaceColor','red', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '2y (pre Ann.)');

        plot(afterHighValues(:, 2), 'LineStyle', '--', 'color', 'blue', ...
            'Marker', 'd', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (post Ann.)');
        plot(beforeHighValues(:, 2), 'LineStyle', '-', 'color', 'blue', ...
            'Marker', 's', 'MarkerFaceColor','blue', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '5y (pre Ann.)');

        plot(afterHighValues(:, 3), 'LineStyle', '--', 'color', 'green', ...
            'Marker', 'd', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (post Ann.)');
        plot(beforeHighValues(:, 3), 'LineStyle', '-', 'color', 'green', ...
            'Marker', 's', 'MarkerFaceColor','green', 'MarkerEdgeColor', ...
            'black', 'DisplayName', '10y (pre Ann.)');

        xticks(1:4); xticklabels({'3m', '6m', '12m', '24m'});
        title({'High Interest Rate Regime', name})

        % export the image to Interest Bucket for VRP measures
        filename = strcat("Output/MacroRegressions/TermStructure/", ...
            volName{:}, "/", event, '.jpg');
        
        exportgraphics(fig, filename);
        
    end
    
end

%% PCA on volatility measures for all 12 swaptions, regression 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% iterate through each volatility data {vrp, blackVol, SigA}
for data = 1:3
    
    % compute the principal component analysis 
    vol = volData{data};
    [~, diff1Vector, ~, ~, explained] = pca(vol{:, 2:end}, ...
        'NumComponents', 1);
    fprintf('1st principal component explains %.4d of variance\n', ...
        explained(1))
    
    % form table with data vector and PCA 1st component 
    volMeasure = table(vol{:, 1}, diff1Vector, 'VariableNames', ...
        {'Date', '1stPC'});
    
    % perform regression on bucket economic releases
    regTB = regression(ecoData, volMeasure, regressVar, ecoMap);
    name = strcat(outDirectory, '/', volFolder{data}, '/', ...
        '/regressPCACoefs.csv');
    
    % write regression coeffcients to table
    writetable(regTB, name);

end

%% PCA on implied volatility for all 12 swaptions across uncertainity

outDirectory = 'Output/MacroRegressions/Regressions/full';

[~, diff1Vector, ~, ~, ~] = pca(blackVol{:, 2:end}, 'NumComponents', 1);
    
% form table with data vector and PCA 1st component 
volMeasure = table(blackVol{:, 1}, diff1Vector, 'VariableNames', ...
    {'Date', '1stPC'});

% perform regression on bucket economic releases
regTB1 = regression(ecoSTD25, volMeasure, regressVar, ecoMap);
regTB2 = regression(ecoSTD75, volMeasure, regressVar, ecoMap);

name1 = strcat(outDirectory, '/iv/regressPCACoefs25bucket.csv');
name2 = strcat(outDirectory, '/iv/regressPCACoefs75bucket.csv');

% write regression coeffcients to table
writetable(regTB1, name1);
writetable(regTB2, name2);


%% PCA on implied volatility for all swaptions across uncertainity and rate regime

outDirectory = 'Output/MacroRegressions/Regressions/full';

[~, diff1Vector, ~, ~, ~] = pca(blackVol{:, 2:end}, 'NumComponents', 1);
    
% form table with data vector and PCA 1st component 
volMeasure = table(blackVol{:, 1}, diff1Vector, 'VariableNames', ...
    {'Date', '1stPC'});

% filter economic dates according to interest rate regime 
filterEco1 = ecoSTD25(ismember(ecoSTD25{:, 1}, highIR{:, 1}), :);
filterEco2 = ecoSTD75(ismember(ecoSTD75{:, 1}, lowIR{:, 1}), :);

% perform regression on bucket economic releases
regTB1 = regression(filterEco1, volMeasure, regressVar, ecoMap);
regTB2 = regression(filterEco2, volMeasure, regressVar, ecoMap);

name1 = strcat(outDirectory, '/iv/regressPCACoefs25bucketHigh.csv');
name2 = strcat(outDirectory, '/iv/regressPCACoefs75bucketLow.csv');

% write regression coeffcients to table
writetable(regTB1, name1);
writetable(regTB2, name2);

% ###################################################################
% fig = figure('visible', 'on');                 
% set(gcf, 'Position', [100, 100, 1500, 600]);
% 
% x1 = filterEco1(ismember(filterEco1.Event, 'Initial Jobless Claims'), :);
% x2 = filterEco2(ismember(filterEco2.Event, 'Initial Jobless Claims'), :);
% 
% % find the intersection between date ranges
% targetDates1 = matchingError(x1, volMeasure, 1);
% targetDates2 = matchingError(x2, volMeasure, 1);
% 
% % computes difference and economic surprise
% [diff1, eco1] = differenceSplit(x1, volMeasure, targetDates1);
% [diff2, eco2] = differenceSplit(x2, volMeasure, targetDates2);
% 
% % perform linear regression with significance
% [est1,~,~,~,~,~,F1] = olsgmm(diff1(:, 1), eco1{:, 'SurpriseZscore'}, 0, 1);
% [est2,~,~,~,~,~,F2] = olsgmm(diff2(:, 1), eco2{:, 'SurpriseZscore'}, 0, 1);
% 
% subplot(1, 2, 1); hold on
% scatter(eco1.SurpriseZscore, diff1, 'DisplayName', 'Raw Data', ...
%     'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'black')
% plot(eco1.SurpriseZscore, eco1.SurpriseZscore*est1, 'LineStyle', '-', ...
%     'LineWidth', 1, 'color', 'red', 'DisplayName', '\beta_0+\beta_1Z_{0.25}^{high}+\epsilon')
% ylabel('Change in Implied Volatility (1st PC)', 'fontsize', 10)
% xlabel('Intial jobless claims Surprise Z-score low uncertainty', 'fontsize', 8)
% title('High interest rate environment')
% legend show
% 
% subplot(1, 2, 2); hold on
% scatter(eco2.SurpriseZscore, diff2, 'DisplayName', 'Raw Data', ...
%     'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'black')
% plot(eco2.SurpriseZscore, eco2.SurpriseZscore*est2, 'LineStyle', '-', ...
%     'LineWidth', 1, 'color', 'red', 'DisplayName', '\beta_0+\beta_1Z_{0.75}^{low}+\epsilon')
% xlabel('Intial jobless claims Surprise Z-score high uncertainty', 'fontsize', 8)
% title('Low interest rate environment')
% legend show
% 
% exportgraphics(fig, 'Output/MacroRegressions/Regressions/full/image.jpg');

%% PCA on volatility measures for all 4 swaption tenors 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB = regression(ecoData, impvolTenorReduced, regressVar, ecoMap);
name = strcat(outDirectory, '/iv/regressTenorPCACoefs.csv');

% write regression coeffcients to table
writetable(regTB, name);

%% PCA on volatility measures for all 4 swaption tenors by uncertainty

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB1 = regression(ecoSTD25, impvolTenorReduced, regressVar, ecoMap);
regTB2 = regression(ecoSTD75, impvolTenorReduced, regressVar, ecoMap);

% perform regression on bucket economic releases
name1 = strcat(outDirectory, '/iv/regressTenorPCACoefs25bucket.csv');
name2 = strcat(outDirectory, '/iv/regressTenorPCACoefs75bucket.csv');

% write regression coeffcients to table
writetable(regTB1, name1);
writetable(regTB2, name2);

%% PCA on volatility measures for all 3 swaption terms 

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB = regression(ecoData, impvolTermReduced, regressVar, ecoMap);
name = strcat(outDirectory, '/iv/regressTermPCACoefs.csv');

% write regression coeffcients to table
writetable(regTB, name);

%% PCA on volatility measures for all 3 swaption terms by uncertainty

outDirectory = 'Output/MacroRegressions/Regressions/full';

% perform regression on bucket economic releases
regTB1 = regression(ecoSTD25, impvolTermReduced, regressVar, ecoMap);
regTB2 = regression(ecoSTD75, impvolTermReduced, regressVar, ecoMap);

name1 = strcat(outDirectory, '/iv/regressTermPCACoefs25bucket.csv');
name2 = strcat(outDirectory, '/iv/regressTermPCACoefs75bucket.csv');

% write regression coeffcients to table
writetable(regTB1, name1);
writetable(regTB2, name2);

%% PCA plot of marco surprises across rate regime and STD bucket 

% itterate through each volatility data set (vrp, iv, rv)
for data = 1:3
    
    % itterate through economic events (e.g. FOMC Rate Decision)
    for i = 1:10
        
        fig = figure('visible', 'off');                 
        set(gcf, 'Position', [100, 100, 1500, 600]);   

        event = keys(i);    % economic event  

        for index = 1:2
            % selects the interest rate environment 
            df = irEnv{:, index};

            % filter economic dates according to interest rate regime 
            filterEco = ecoData(ismember(ecoData{:, 1}, df{:, 1}), :);

            % filter data by macro economic event
            filterData = filterEco(ismember(filterEco{:, 'Ticker'}, ...
                event), :);

            % compute the top and bottom forecast STD percentile per event
            bottom10 = quantile(filterData.StdDev, .10);
            bottom25 = quantile(filterData.StdDev, .25);
            top25 = quantile(filterData.StdDev, .75);
            top10 = quantile(filterData.StdDev, .90);

            % bucket out economic figures according to std value
            ecoBin1 = filterData((filterData.StdDev <= bottom10), :);
            ecoBin2 = filterData((filterData.StdDev <= bottom25), :);
            ecoBin3 = filterData((filterData.StdDev >= top25), :);
            ecoBin4 = filterData((filterData.StdDev >= top10), :);
            
            volSelection = volData{data};
            
            % compute the principal component analysis 
            [~, component, ~, ~, ~] = pca(volSelection{:, 2:end}, ...
                'NumComponents', 1);

            % form table with data vector and PCA 1st component 
            volMeasure = table(volSelection{:, 1}, component, ...
                'VariableNames', {'Date', '1stPC'});
            
            % match target dates for each STD period 
            datesBin1 = matchingError(ecoBin1, volMeasure, 1);
            datesBin2 = matchingError(ecoBin2, volMeasure, 1);
            datesBin3 = matchingError(ecoBin3, volMeasure, 1);
            datesBin4 = matchingError(ecoBin4, volMeasure, 1);

            % change in regressed values pre-post announcement 
            [diffBin1, ~] = differenceSplit(ecoBin1, volMeasure, ...
                datesBin1);
            [diffBin2, ~] = differenceSplit(ecoBin2, volMeasure, ...
                datesBin2);
            [diffBin3, ~] = differenceSplit(ecoBin3, volMeasure, ...
                datesBin3);
            [diffBin4, ~] = differenceSplit(ecoBin4, volMeasure, ...
                datesBin4);

            % building out the average difference cell per STD period
            % function computes the mean, column wise (per each security) 
            y = [mean(diffBin1, 'omitnan'), mean(diffBin2, 'omitnan'), ...
                mean(diffBin3, 'omitnan'), mean(diffBin4, 'omitnan')];

            % plotting out the bucket changes by positive/negative leaning
            subplot(1, 2, index);
            bar(1:4, y); title(strcat(rateNames(index), ...
                ' Rate Environment'));
            xticks([1, 2, 3, 4]); 
            xticklabels({'10th', '25th', '75th', '90th'});
            ylim([min(y)-0.5, max(y)+0.5])
            xlabel({string(econVars(i)), ...
                'Forecast Standard Deviation Percentile'}, 'FontSize', 8);
        end

        subplot(1, 2, 1);
        ylabel("Average Change to Macro-surprise", 'FontSize', 9);
        legend('show', strcat("1st Principal Component in ", ...
            volNames{data}), 'location', 'best')
        
        % export the image to Interest Bucket for VRP measures
        name = strcat("Output/MacroRegressions/StdBuckets/", ...
            volFolder{data}, "/", event, ".jpg");
        exportgraphics(fig, name);

    end
  
end

