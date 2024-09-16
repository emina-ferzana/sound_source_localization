function [rssi_loc_estimates, rmse] = ...
                    rssi_based_localization(loc_source_init, loc_source_gt, ...
                                            audio_dir)

    % okvir 1
    mic_1 = [0.015,0,0]; % horizontalni stereo par
    mic_2 = [1.01,0,0];
    mic_3 = [0,0,0]; % vertikalni stereo par
    mic_4 = [0,0,1.01];
    
    % okvir 2 
    mic_5 = [4.07,0.22,0];
    mic_6 = [5.05,0.22,0];
    mic_7 = [4.06,0.22,0];
    mic_8 = [4.02,0.22,1.01];
    
    % okvir 3 
    mic_9 = [0.62 , 6.34, 0 ];
    mic_10 = [-0.4, 6.34, 0];
    mic_11 = [0.63, 6.34, 0];
    mic_12 = [0.63,6.34,1.01];
    
    %okvir 4 
    mic_13 = [4.35, 6.34, -0.22];
    mic_14 = [3.34, 6.34, -0.22];
    mic_15 = [4.36, 6.34, -0.22];
    mic_16 = [4.36, 6.34, 0.79];
    
    % mikrofoni na stropu
    mic_18 = [0,-0.6,-1.13];
    mic_17 = [5.4,-0.6,-1.13];
    mic_19 = [0,5.4,-1.1];
    mic_20 = [5.4,5.4,-1.1];
    
    
    Mic1 = struct();
    Mic1.left = mic_1;
    Mic1.right = mic_2;
    Mic2 = struct();
    Mic2.left = mic_3;
    Mic2.right = mic_4;
    Mic3 = struct();
    Mic3.left = mic_5;
    Mic3.right = mic_6;
    Mic4 = struct();
    Mic4.left = mic_7;
    Mic4.right = mic_8;
    Mic5 = struct();
    Mic5.left = mic_9;
    Mic5.right = mic_10; 
    Mic6 = struct();
    Mic6.left = mic_11;
    Mic6.right = mic_12; 
    Mic7 = struct();
    Mic7.left = mic_13;
    Mic7.right = mic_14;
    Mic8 = struct();
    Mic8.left = mic_15;
    Mic8.right = mic_16;
    
    mics_upper = [Mic1, Mic3, Mic5, Mic7];
    mics_lower = [Mic2, Mic4, Mic6, Mic8];
    ceiling = [mic_17; mic_18; mic_19; mic_20];
    
    %audio_dir = fullfile('/home/eminaf/experiment_data', timestamp_dir);
    files = dir(fullfile('~', audio_dir, 'mic_0','left_channel','*.wav')); 
    base_dir = fullfile('~',audio_dir);
    %get number of files/sounds 
    rssi_loc_estimates = zeros(length(files), 3);
    
    % Optimization parameters
    max_iter = 200; % Maximum number of iterations
    tol = 1e-2; % Convergence tolerance
        
        
    figure;
    plot_handles = [];
    colors = lines(length(files)); % 'lines' colormap gives distinct colors
    number_of_iterations = [];
    
    fprintf("Calculating the power and distance ratios...\n");
    for i = 1:length(files)
    
        [loc_source_est, residuals] = gauss_newton_localization_rssi(mics_upper,...
            mics_lower, ceiling, i, base_dir, loc_source_init, max_iter, tol);
        rssi_loc_estimates(i,:) = loc_source_est;
        
        hold on;
        h = plot(residuals, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', colors(i,:), 'Color', colors(i,:));
        plot_handles = [plot_handles, h];
        hold off;

        number_of_iterations = [number_of_iterations; length(residuals)];
    end
    
    xlabel('Iteration', 'FontSize', 12);
    ylabel('Residual Norm', 'FontSize', 12);
    title('RSSI-based localization via Gauss-Newton');
    grid on;
    set(gca, 'FontSize', 12, 'LineWidth', 1.5); 
    legend_text = arrayfun(@(x) sprintf('Transient %d', x), ...
        1:length(files), 'UniformOutput', false);
    legend(plot_handles, legend_text, 'Location', 'Best');
    
    rssi_loc_estimates = rssi_loc_estimates(1:end-1,:); % Zadnji rezultat
    % izločimo iz statistike, saj je metode konvergirala izven dimenzij
    % sobe
    mean_loc = mean(rssi_loc_estimates);
    fprintf(['Mean of Gauss-Newton estimates of source location for all files: \n' ...
         '(x = %.2f, y = %.2f, z = %.2f)\n'], ...
         mean_loc(1), mean_loc(2), mean_loc(3));

    rmse = get_rmse(loc_source_gt, rssi_loc_estimates);
    
    fprintf('Mean of iterations: %f +- %f\n', mean(number_of_iterations), ...
        std(number_of_iterations));

end
function RMSE = get_rmse(gt, estimated_locations)

    squared_error_sum = 0;
    n = size(estimated_locations, 1);
    
    % Loop through each estimated location and calculate the squared error
    for i = 1:n
        estimated_loc = estimated_locations(i, :);
        squared_error = (estimated_loc(1) - gt(1))^2 + ...
                        (estimated_loc(2) - gt(2))^2 + ...
                        (estimated_loc(3) - gt(3))^2;
        squared_error_sum = squared_error_sum + squared_error;
    end
    
    RMSE = sqrt(squared_error_sum / n);
    fprintf('The RMSE for this experiment is: %.4f m\n', RMSE);
end