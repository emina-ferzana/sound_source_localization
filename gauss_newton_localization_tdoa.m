function [loc_source_est, residuals,avg_iter_time] = ...
            gauss_newton_localization_tdoa(delay_matrix, mic_positions, ...
            loc_source_init, max_iter, tol)

    c = 343; % Speed of sound in m/s
    loc_source_est = loc_source_init;
    num_mics = size(mic_positions, 1);


    residuals = [];
    total_time = 0;
    for iter = 1:max_iter

        % Start timing the iteration
        iter_start = tic;

        f = [];
        J = [];

        for i = 1:num_mics
            for j = i+1:num_mics
                if ~isnan(delay_matrix(i, j))
                    % Calculate TDOA estimated
                    tdoa_measured = delay_matrix(i, j);
                    mic_x_pos = mic_positions(i, :);
                    mic_y_pos = mic_positions(j, :);

                    % Estimated TDOA based on current source estimate
                    dist_x = norm(loc_source_est - mic_x_pos);
                    dist_y = norm(loc_source_est - mic_y_pos);
                    tdoa_estimated = (dist_x - dist_y) / c;

                    % Residual
                    f = [f; tdoa_estimated - tdoa_measured];

                    % Jacobian
                    Jx = -(mic_x_pos(1) - loc_source_est(1)) / (c * dist_x) + (mic_y_pos(1) - loc_source_est(1)) / (c * dist_y);
                    Jy = -(mic_x_pos(2) - loc_source_est(2)) / (c * dist_x) + (mic_y_pos(2) - loc_source_est(2)) / (c * dist_y);
                    Jz = -(mic_x_pos(3) - loc_source_est(3)) / (c * dist_x) + (mic_y_pos(3) - loc_source_est(3)) / (c * dist_y);
                    J = [J; Jx Jy Jz];
                end
            end
        end

        % posodobi oceno položaja vira zvoka
        delta = -pinv(J' * J) * J' * f;
        loc_source_est = loc_source_est + delta';

        % shrani normo residuala
        f = norm(f);
        residuals = [residuals; f];

        % čas trajanja trenutne iteracije
        iter_time = toc(iter_start);
        total_time = total_time + iter_time;

        % ali je izpolnjen pogoj za konvergenco?
        if norm(delta) < tol
            break;
        end
    end
    % povprečni čas trajanja ene iteracije
    avg_iter_time = total_time / iter;
end