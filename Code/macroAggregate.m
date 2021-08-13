% Perform cumulative return analysis versus macroeconomic variables 

clearvars -except root_dir;

% loading in economic and volatility data
load TT-Puzzle bps_mp bps_mp_m

load DATA yeildCurve ecoMap iv vrp ecoData


%% Measuring the aggregate impact of macro-annoucements on TIPS-Treasury mispricing

for event = ecoMap.keys
 
    % filter the corresponding economic annoucments and retrieve the name
    macro_event = ecoData(ismember(ecoData.NAME, event), :);
    macro_name = macro_event{1, 'NAME'};
    
    % annoucement date for economic measurements
    % NOTE: This should always be the first column of the economic table
    annoucements = macro_event{:, 1};

    % find the intersection between date ranges for pre-post annoucement
    target_dates = find(ismember(bps_mp.date, annoucements));
    other_dates = find(~ismember(bps_mp.date, annoucements));

    % target date windows for pre-post announcement 
    post_annouce = bps_mp(target_dates, {'med', 'long', 'aggregate'});
    pre_annouce = bps_mp(target_dates-1, {'med', 'long', 'aggregate'});

    % all other macro dates (we avoid first row to compute change)
    post_other = bps_mp(other_dates(2:end), {'med', 'long', 'aggregate'});
    pre_other = bps_mp(other_dates(2:end)-1, {'med', 'long', 'aggregate'});

    % compute the change across tthe basis both abolsolute and raw differences
    % (we standardize by dividing each change by the length of the data set) 
    abs_anc_calc = abs(post_annouce{:, :} - pre_annouce{:, :}) ./ size(post_annouce, 1);
    abs_other_calc = abs(post_other{:, :} - pre_other{:, :}) ./ size(post_other, 1);

    raw_anc_calc = (post_annouce{:, :} - pre_annouce{:, :}) ./ size(post_annouce, 1);
    raw_other_calc = (post_other{:, :} - pre_other{:, :}) ./ size(post_other, 1);

    % -----------------------------------------------------------------------
    % Medium Term Bucket
    % -----------------------------------------------------------------------
    fig1 = figure('visible', 'off');                  % prevent display 
    set(gcf, 'Position', [100, 100, 1250, 650]);     % setting figure dims

    subplot(1, 2, 1); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Absolute Cumulative Changes (Medium Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(abs_other_calc(:, 1)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(abs_anc_calc(:, 1)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off

    % -----------------------------------------------------------------------

    subplot(1, 2, 2); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Raw Cumulative Changes (Medium Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(raw_other_calc(:, 1)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(raw_anc_calc(:, 1)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off
    
    % -----------------------------------------------------------------------
    % Long Term Bucket
    % -----------------------------------------------------------------------
    fig2 = figure('visible', 'off');                  % prevent display 
    set(gcf, 'Position', [100, 100, 1250, 650]);     % setting figure dims

    subplot(1, 2, 1); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Absolute Cumulative Changes (Long Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(abs_other_calc(:, 2)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(abs_anc_calc(:, 2)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off

    % -----------------------------------------------------------------------

    subplot(1, 2, 2); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Raw Cumulative Changes (Long Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(raw_other_calc(:, 2)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(raw_anc_calc(:, 2)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off
    
    % -----------------------------------------------------------------------
    % Aggregate Term Bucket
    % -----------------------------------------------------------------------
    fig3 = figure('visible', 'off');                  % prevent display 
    set(gcf, 'Position', [100, 100, 1250, 650]);      % setting figure dims

    subplot(1, 2, 1); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Absolute Cumulative Changes (Aggregate Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(abs_other_calc(:, 3)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(abs_anc_calc(:, 3)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off

    % -----------------------------------------------------------------------

    subplot(1, 2, 2); hold on; 
    title({'Response of TIPS-Treasury Mispricing', 'Raw Cumulative Changes (Aggregate Bucket)'})
    h(1, 1) = plot(bps_mp(other_dates(2:end), :).date, cumsum(raw_other_calc(:, 3)), ...
        'Color', 'blue', 'DisplayName', strcat('Non-', macro_name{:}), ...
        'LineWidth', 2, 'LineStyle', '--');
    h(1, 2) = plot(bps_mp(target_dates, :).date, cumsum(raw_anc_calc(:, 3)), ...
        'Color', 'black', 'DisplayName', macro_name{:}, 'LineWidth', 3);

    % FED Quantitative Easing 1 (11/25/2008)
    qe1 = datetime(2008, 11, 25); xline(qe1, '--r', {'QE 1'}, 'LineWidth', 1);  

    % FED Quantitative Easing 2 (9/13/2010)
    qe2 = datetime(2010, 11, 3); xline(qe2, '--r', {'QE 2'}, 'LineWidth', 1);   

    % FED Quantitative Easing 3 (9/13/2012)
    qe3 = datetime(2012, 9, 13); xline(qe3, '--r', {'QE 3'}, 'LineWidth', 1);   

    legend(h, 'FontSize', 10, 'Location', 'Southeast')
    hold off
    
    % export all graphs to corresponding folders
    exportgraphics(fig1, strcat('Output/macro-announcements/responses/', ...
        macro_name{:}, ' Medium Bucket.png'));
    exportgraphics(fig2, strcat('Output/macro-announcements/responses/', ...
        macro_name{:}, ' Long Bucket.png'));
    exportgraphics(fig3, strcat('Output/macro-announcements/responses/', ...
        macro_name{:}, ' Aggregate Bucket.png'));

end

%% 

fprintf('All macro-aggregated series are completed.\n')
