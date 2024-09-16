function [horizontal_angle_estimations,vertical_angle_estimations, ...
    mean_values_vertical, std_values_vertical,...
    mean_values_horizontal, std_values_horizontal] = ssl_clap_automated_experiment_aoa(audio_dir)
    % Define base directory and mic pairs
    %base_dir = fullfile('/home/eminaf/experiment_data', timestamp_folder);
    base_dir = fullfile('~', audio_dir);
    mic_pairs = {
        'mic_1', 'mic_1';
        'mic_2', 'mic_2';
        'mic_3', 'mic_3';
        'mic_4', 'mic_4';
        'mic_5', 'mic_5';
        'mic_6', 'mic_6';
        'mic_7', 'mic_7';
        'mic_8', 'mic_8'
    };
    channels = {'left_channel', 'right_channel'};

    % Initialize arrays to store angle estimations
    num_pairs = length(mic_pairs);
    num_files = length(dir(fullfile(base_dir, mic_pairs{1,1}, channels{1}, '*.wav')));
    vertical_angle_estimations = nan(num_files, num_pairs);
    horizontal_angle_estimations = nan(num_files, num_pairs);

    for pair_idx = 1:num_pairs
        % Get the directories for the current mic pair
        mic_left = mic_pairs{pair_idx, 1};
        mic_right = mic_pairs{pair_idx, 2};
        
        basedir_left = fullfile(base_dir, mic_left, channels{1});
        basedir_right = fullfile(base_dir, mic_right, channels{2});

        files = dir(fullfile(basedir_right, '*.wav'));
        num_files = length(files);

        for idx = 1:num_files
            file_path_right = fullfile(basedir_right, files(idx).name);
            file_path_left = fullfile(basedir_left, files(idx).name);

            try
                [y_right, Fs_right] = audioread(file_path_right);
                [y_left, Fs_left] = audioread(file_path_left);
            catch
                warning('Error reading file: %s', files(idx).name);
                continue;
            end

            % Calculate the delay using GCC-PHAT
            lag_range = 129; % Max. lag range for stereo pairs
            [delay_samples, delay] = gcc_phat_ssl(y_left, y_right, Fs_right, lag_range);
            
            c = 343;
            baseline = 1.02; % Adjust the baseline as necessary
            travel_difference = c * delay;
            angle_rad = acos(travel_difference / baseline);
            angle_deg = angle_rad * 180 / pi;
            
            % Determine whether the pair is vertical or horizontal
            if pair_idx == 2 || pair_idx == 4 || pair_idx == 6 || pair_idx == 8
                vertical_angle_estimations(idx, pair_idx) = angle_deg;
            else
                horizontal_angle_estimations(idx, pair_idx) = angle_deg;
            end
        end
    end

    % Calculate mean and standard deviation for vertical angles
    mean_values_vertical = nan(1, num_pairs);
    std_values_vertical = nan(1, num_pairs);
    for i = 1:num_pairs
        mean_values_vertical(1,i) = mean(vertical_angle_estimations(:, i), 'all', 'omitnan');
        std_values_vertical(1,i) = std(vertical_angle_estimations(:,i), 0, 'all', 'omitnan');
    end

    % Calculate mean and standard deviation for horizontal angles
    mean_values_horizontal = nan(1, num_pairs);
    std_values_horizontal = nan(1, num_pairs);
    for i = 1:num_pairs
        mean_values_horizontal(1,i) = mean(horizontal_angle_estimations(:,i), 'all', 'omitnan');
        std_values_horizontal(1,i) = std(horizontal_angle_estimations(:,i), 0, 'all', 'omitnan');
    end
end