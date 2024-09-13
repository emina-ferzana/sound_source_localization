%scriptName = '/home/eminaf/experiment_data/organize_experiment_files.sh';
%[status, cmdout] = system(scriptName);
status = 0;
if status == 0
    disp('Datoteke eksperimenta so bile uspešno organizirane!');
    disp(cmdout); 

    % pridobi informacijo o časovnem žigu, ker je tako bila poimenovana
    % mapa z datotekami eksperimenta
    %timestamp_dir = strtrim(cmdout);
    timestamp_dir = '20240913103628';
    % izvleči tranziente iz dolgega posnetka in jih shrani v ustrezne
    % posamezne datoteke
    %ssl_clap_automated_experiment_more_mics(timestamp_dir);

    [horizontal_angle_estimations, vertical_angle_estimations, ...
        mean_values_vertical, std_values_vertical, ...
        mean_values_horizontal, std_values_horizontal] = ...
        ssl_clap_automated_experiment_aoa(timestamp_dir);

    plot_all_mics(mean_values_horizontal, mean_values_vertical, ...
        std_values_horizontal, std_values_vertical);

    %provide the ground truth for the source position and an initial
    %estimate based on the intersection of the AOA lines for all 4 sensors
    loc_source_gt = [2.9,3,1.24];
    loc_source_init = [2.5, 3.03, 1.1];

    fprintf("\nTDOA-based localization:\n");
    % [tdoa_locs, tdoa_rmse] = tdoa_based_localization(loc_source_init, ...
    % loc_source_gt, timestamp_dir);
    
    fprintf("\nRSSI-based localization:\n");
    % [rssi_locs, rssi_rmse] = rssi_based_localization(loc_source_init, ...
    % loc_source_gt, timestamp_dir);

    fprintf("\nGrid evaluation:\n");
    fprintf("\nThis may take a while...\n");
    fprintf(['The grid evaluation is being saved to mat files ' ...
         'in loss_func_output/%s\n'], timestamp_dir);

    %fine_grid_search_tdoa_rssi(timestamp_dir);

    addpath('loss_func_output');
    visualize_grids(timestamp_dir, 3);
    
else
    disp('Error in executing script');
    disp(cmdout);
end
