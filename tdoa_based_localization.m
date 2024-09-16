function [estimated_src_locations, rmse] = tdoa_based_localization(loc_source_init, ...
    loc_source_gt, audio_dir)
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
    
    mic_positions = [ ...
        mic_17; mic_18; mic_19;mic_20; %mikrofoni na stropu
        mic_1; mic_2; mic_3; mic_4; ... % Frame 1
        mic_5; mic_6; mic_7; mic_8; ... % Frame 2
        mic_9; mic_10; mic_11; mic_12; ... % Frame 3
        mic_13; mic_14; mic_15; mic_16 ... % Frame 4
    ];
    
    % Input file 
    %timestamp_dir = '20240805145919';
    fprintf("Calculating the delay matrices via GCC-PHAT...\n");
    base_dir = fullfile('~',audio_dir);
    delay_matrices = ssl_clap_automated_experiment_gcc_phat_more_mics(base_dir);
    
    
    % Optimization parameters
    %loc_source_init = [2.5, 3.03, 1.1]; % Initial guess for source location
    %loc_source_gt = [2.9,3,1.24];
    max_iter = 100; % Maximum number of iterations
    tol = 1e-6; % Convergence tolerance
    
    estimated_src_locations = [];
    avg_times = [];
    
    figure;
    plot_handles = [];
    colors = lines(length(delay_matrices)); % 'lines' colormap gives distinct colors
    number_of_iterations = []; % number of iterations the algortihm took to converge
    
    fprintf("Running the optimization algorithm...\n")
    for i = 1:length(delay_matrices)
    
        delay_matrix = delay_matrices{i};
        [loc_source_est, residuals, average_iter_time] = ...
            gauss_newton_localization_tdoa(delay_matrix, mic_positions, ...
            loc_source_init, max_iter, tol);
        estimated_src_locations = [estimated_src_locations; loc_source_est];
        avg_times = [avg_times; average_iter_time];
    
        
        hold on;
        h = plot(residuals, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', colors(i,:), 'Color', colors(i,:));
        plot_handles = [plot_handles, h];  
        hold off;
    
        number_of_iterations = [number_of_iterations; length(residuals)];
    
    end
    
    
    xlabel('Iteration', 'FontSize', 12);
    ylabel('Residual Norm', 'FontSize', 12);
    title('TDOA-based localization via Gauss-Newton');
    grid on;
    set(gca, 'FontSize', 12, 'LineWidth', 1.5);
    
    
    legend_text = arrayfun(@(x) sprintf('Transient %d', x), 1:length(delay_matrices), 'UniformOutput', false);
    legend(plot_handles, legend_text, 'Location', 'Best');
    
    
    mean_loc = mean(estimated_src_locations);
   fprintf(['Mean of Gauss-Newton estimates of source location for all files: \n' ...
         '(x = %.2f, y = %.2f, z = %.2f)\n'], ...
         mean_loc(1), mean_loc(2), mean_loc(3));

    rmse = get_rmse(loc_source_gt, estimated_src_locations);
    fprintf('Average duration of one iteration: %f +- %f\n',...
        mean(avg_times), std(avg_times));
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
    
    % Display the RMSE
    fprintf('The RMSE for this experiment is: %.4f m\n', RMSE);
end
