function delay_matrices = ssl_clap_automated_experiment_gcc_phat_more_mics(audio_dir)
    % Define base directory and parameters
    %base_dir = fullfile('/home/eminaf/experiment_data', timestamp_folder);
    base_dir =  audio_dir;
    mic_dirs = dir(fullfile(base_dir, 'mic_*'));
    channels = {'left_channel', 'right_channel'};
    channels_add = {'left_channel', 'right_channel', 'channel3_channel', 'channel4_channel'};
    num_mics = (length(mic_dirs) - 1) * 2 + 4; % 2 channels per mic + 4 additinal mics on the ceiling

    % Get the number of files in the directories (assuming each dir has the same number of files)
    num_files = length(dir(fullfile(base_dir, mic_dirs(1).name, 'left_channel', '*.wav')));
    
    % Initialize a cell array to store delay matrices
    delay_matrices = cell(num_files, 1);

    for file_idx = 1:num_files
        % Initialize the delay matrix for the current file
        delay_matrix = nan(num_mics, num_mics); 

        % Loop through all microphone combinations, including within the same mic directory
        for mic1_idx = 1:length(mic_dirs)
            mic1_dir = mic_dirs(mic1_idx).name;

            % Determine the number of channels to process (only mics on the
            % ceiling have 4 channels)
            if mic1_idx == 1
                ch1_list = channels_add;
                num_channels1 = 4;
            else
                ch1_list = channels;
                num_channels1 = 2;
            end

            for ch1_idx = 1:num_channels1 
                basedir_left = fullfile(base_dir, mic1_dir, ch1_list{ch1_idx});

                % Check within the same mic directory (left vs right channel)
                for ch2_idx = ch1_idx+1:num_channels1 
                    % 1 for left_channel, 2 for right_channel 
                    % (3 or 4 for the additional mics)
                    basedir_right = fullfile(base_dir, mic1_dir, ...
                                             ch1_list{ch2_idx});
                    if mic1_idx == 1
                        lag_range = 694; % lag range for the baseline 5.4m
                    else 
                        lag_range = 129; % Lag range for the baseline = 1m
                    end
                    delay = process_files_gcc_phat(basedir_left, ...
                                        basedir_right, file_idx, lag_range);
                    if mic1_idx == 1
                        mic1_num = (mic1_idx - 1) * 2 + ch1_idx;
                        mic2_num = (mic1_idx - 1) * 2 + ch2_idx;
                    else 
                        mic1_num = mic1_idx * 2 + ch1_idx;
                        mic2_num = mic1_idx * 2 + ch2_idx;
                    end

                    if isnan( delay_matrix(mic1_num, mic2_num))
                        delay_matrix(mic1_num, mic2_num) = delay;
                    else
                        sprintf("Warning, overwriting existing data, check " + ...
                            "your indexing.\n");
                    end 
                end

                % Check with other mic directories (all other mics have
                % only 2 channels)
                for mic2_idx = mic1_idx+1:length(mic_dirs)
                    mic2_dir = mic_dirs(mic2_idx).name;

                    for ch2_idx = 1:2 % 1 for left_channel, 2 for right_channel
                        basedir_right = fullfile(base_dir, mic2_dir, channels{ch2_idx});

                        %lag_range = 900; % Lag range for different mic directories
                        lag_range = 1028; 
                        delay = process_files_gcc_phat(basedir_left, basedir_right, file_idx, lag_range);

                        if mic1_idx == 1
                            mic1_num = (mic1_idx - 1) * 2 + ch1_idx;
                        else 
                            mic1_num = mic1_idx * 2 + ch1_idx;
                        end
                    
                        mic2_num = mic2_idx * 2 + ch2_idx;
                        delay_matrix(mic1_num, mic2_num) = delay;
                    end
                end
            end
        end
        % Display the delay matrix for the current file
        % fprintf('Delay Matrix for File %d (in seconds):\n', file_idx);
        % disp(delay_matrix);
        % Store the delay matrix for the current file in the cell array
        delay_matrices{file_idx} = delay_matrix;
    end
end