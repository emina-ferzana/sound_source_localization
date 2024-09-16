function [mean_values_vertical, std_values_vertical, ...
    mean_values_horizontal, std_values_horizontal,...
    tdoa_locs, tdoa_rmse,rssi_locs, rssi_rmse] = get_all_localization_results(audio_dir)



    % izvleči tranziente iz dolgega posnetka in jih shrani v ustrezne
    % posamezne datoteke
    % ssl_clap_automated_experiment_more_mics(audio_dir);
    
    [horizontal_angle_estimations, vertical_angle_estimations, ...
        mean_values_vertical, std_values_vertical, ...
        mean_values_horizontal, std_values_horizontal] = ...
        ssl_clap_automated_experiment_aoa(audio_dir);
    
    plot_all_mics(mean_values_horizontal, mean_values_vertical, ...
        std_values_horizontal, std_values_vertical);
    
    %provide the ground truth for the source position and an initial
    %estimate based on the intersection of the AOA lines for all 4 sensors
    loc_source_gt = [2.9,3,1.24];
    loc_source_init = [2.5, 3.03, 1.1];
    
    fprintf("\nTDOA-based localization:\n");
    [tdoa_locs, tdoa_rmse] = tdoa_based_localization(loc_source_init, ...
    loc_source_gt, audio_dir);
    
    fprintf("\nRSSI-based localization:\n");
    [rssi_locs, rssi_rmse] = rssi_based_localization(loc_source_init, ...
    loc_source_gt, audio_dir);
    
    fprintf("\nGrid evaluation:\n");
    fprintf("\nThis may take a while...\n");
    fprintf(['The grid evaluation is being saved to mat files ' ...
         'in loss_func_output/%s\n'], audio_dir);
    
    %fine_grid_search_tdoa_rssi(audio_dir);
    
    addpath('loss_func_output');
    visualize_grids(audio_dir, 3);

end
