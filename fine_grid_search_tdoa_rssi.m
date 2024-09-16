function fine_grid_search_tdoa_rssi(files_dir)
    % Preparing the variables

    % initialize the room as a grid
    room_width = 6;
    room_length = 7;
    room_height = 4;
    grid_el = 0.25;
    loss_func_values = zeros(room_width/grid_el, ...
                            room_length/grid_el, ...
                            room_height/grid_el);
    
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


    base_dir= fullfile('~', files_dir);
    parts = split( base_dir, '/');
    last_part_dir = parts{end};
    output_dir = fullfile('loss_func_output', last_part_dir);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % TDOA part
    delay_matrices = ssl_clap_automated_experiment_gcc_phat_more_mics(base_dir);
    channels_add = {'left_channel', 'right_channel', 'channel3_channel', 'channel4_channel'};

    
    
    for idx_file = 1:length(delay_matrices)
    
        delay_matrix = delay_matrices{idx_file};
            
        for x_coord = 1:size(loss_func_values, 1)
            for y_coord = 1:size(loss_func_values, 2)
                for z_coord = 1:size(loss_func_values, 3)
                    candidate_pos_x = (x_coord) * grid_el - grid_el / 2;
                    candidate_pos_y = (y_coord) * grid_el - grid_el / 2;
                    candidate_pos_z = ((z_coord) * grid_el - grid_el / 2) - 1.2;
                    source_position = [candidate_pos_x, candidate_pos_y, candidate_pos_z];
                    
                    loss_func_values(x_coord, y_coord, z_coord) = ...
                        objective_function_tdoa(source_position, mic_positions, delay_matrix);
                end
            end
        end
    
        % Save the loss function values matrix to a .mat file
        save(fullfile(output_dir, sprintf( ...
            'loss_func_values_tdoa_file_%d.mat', idx_file)), ...
            'loss_func_values');    
    end
    
    % RSSI part
    
    
    for idx_file = 1:length(delay_matrices)
        distance_ratios_one_file = [];
        
        for ceil_idx = 1:length(ceiling)
            power_ceiling = extract_transient_and_calculate_power_ceiling_mic...
                (base_dir, channels_add{ceil_idx}, idx_file);
            % we will combine each ceiling mic with every other mic from the
            % frames 
    
            for i = 1:length(mics_upper)
                % Read the files for Mic i
                idx_mic_i = (i - 1) * 2 + 1; % calculate the microphone index 
                % horizontal pairs (mics_upper)
                idx_mic_vert_i = 2 * i; % calculate the microphone index for
                % vertical pairs (mics_lower)
                
                [power_left_i, power_right_i] = extract_transient_and_calculate_power(base_dir, idx_mic_i, idx_file);
                [power_left_vert_i, power_right_vert_i] = extract_transient_and_calculate_power(base_dir, idx_mic_vert_i, idx_file);
               
                for j = i+1:length(mics_upper)      
                    % Read the files for Mic j 
                    idx_mic_j = (j - 1) * 2 + 1;
                    [power_left_j, power_right_j] = extract_transient_and_calculate_power(base_dir, idx_mic_j, idx_file);            
                    
                    % Do that for the vertical pairs (mics_lower)
                    idx_mic_vert_j = j * 2;
                    [power_left_vert_j, power_right_vert_j] = extract_transient_and_calculate_power(base_dir, idx_mic_vert_j, idx_file);
                 
                    % Combine all relevant pairs and calculate ratios
                    ratios = [
                        distance_ratio(power_left_i, power_left_j), ...
                        distance_ratio(power_left_i, power_right_j), ...
                        distance_ratio(power_right_i, power_left_j), ...
                        distance_ratio(power_right_i, power_right_j), ...
                        distance_ratio(power_left_vert_i, power_right_vert_j), ...
                        distance_ratio(power_right_vert_i, power_left_vert_j), ...
                        distance_ratio(power_right_i, power_right_vert_j), ...
                        distance_ratio(power_ceiling, power_left_i), ...
                        distance_ratio(power_ceiling, power_right_i), ...
                        distance_ratio(power_ceiling, power_left_vert_i), ...
                        distance_ratio(power_ceiling, power_right_vert_i), ...
                        distance_ratio(power_ceiling, power_left_j), ...
                        distance_ratio(power_ceiling, power_right_j), ...
                        distance_ratio(power_ceiling, power_left_vert_j), ...
                        distance_ratio(power_ceiling, power_right_vert_j)
                    ];
        
                    % Store the ratios in the variable
                    distance_ratios_one_file = [distance_ratios_one_file; ratios];
                end
            end
        end
    
        % search the entire grid, calculate the loss func for each candidate
        for x_coord = 1:size(loss_func_values,1)
            for y_coord = 1:size(loss_func_values,2)
                for z_coord = 1:size(loss_func_values,3)
                    candidate_pos_x = (x_coord) * grid_el - grid_el/2;
                    candidate_pos_y = (y_coord) * grid_el - grid_el/2;
                    candidate_pos_z = (z_coord) * grid_el - grid_el/2;
                    source_position = [candidate_pos_x, ...
                                    candidate_pos_y, candidate_pos_z];
          
                    loss_func_values(x_coord, y_coord, z_coord) = ...
                            objective_function_rssi(source_position, ...
                            mics_upper, mics_lower, ceiling, ...
                            distance_ratios_one_file);
                end
            end
        end
    
    
        % Save the loss function values matrix to a .mat file
        save(fullfile(output_dir, ...
            sprintf('loss_func_values_rssi_ file_%d.mat', idx_file)), ...
            'loss_func_values');   
    
    end
end
%% Local functions
function error = objective_function_tdoa(source_pos, mic_positions, tdoa_matrix)
    num_mics = size(mic_positions, 1);
    estimated_tdoas = zeros(num_mics, num_mics);

    for i = 1:num_mics
        for j = i+1:num_mics
            d_i = norm(source_pos - mic_positions(i, :));
            d_j = norm(source_pos - mic_positions(j, :));
            estimated_tdoas(i, j) = (d_i - d_j) / 343; % Speed of sound in air (343 m/s)
        end
    end

    % Calculate error as sum of squared differences
    upper_triangle_indices = find(triu(ones(num_mics, num_mics), 1));
    measured_tdoas = tdoa_matrix(upper_triangle_indices);
    estimated_tdoas = estimated_tdoas(upper_triangle_indices);
    error = sum((measured_tdoas - estimated_tdoas).^2);
end



function power = calculate_power(signal)
    signal = signal - mean(signal);
    power = mean(signal .^ 2);
end

function power = extract_transient_and_calculate_power_ceiling_mic ...
                                        (audio_dir, channel, file_index)


    channel_dir = fullfile(audio_dir, 'mic_0', channel);  
    channel_files = dir(fullfile(channel_dir, '*.wav'));
    file_channel = fullfile(channel_dir, channel_files(file_index).name);
    [signal, Fs] = audioread(file_channel);
   
    % Find transients 
    transient = transient_detector_func(signal, Fs);
    transient_samples = transient * Fs; 
   
    % Cut out only the 100 ms transient 
    transient_length = 0.1 * 44100; % 100ms length of samples
    signal = signal(transient_samples: ...
                        transient_length + transient_samples);
   
    power = calculate_power(signal);
end

function [power_left_channel, power_right_channel] = extract_transient_and_calculate_power(audio_dir, mic_index, file_index)

    left_dir = fullfile(audio_dir, ['mic_', num2str(mic_index)], 'left_channel');
    right_dir = fullfile(audio_dir, ['mic_', num2str(mic_index)], 'right_channel');
    
    left_files = dir(fullfile(left_dir, '*.wav'));
    right_files = dir(fullfile(right_dir, '*.wav'));
    
    file_left = fullfile(left_dir, left_files(file_index).name);
    file_right = fullfile(right_dir, right_files(file_index).name);
    
    [left_signal, Fs] = audioread(file_left);
    [right_signal, Fs] = audioread(file_right);
   
    %find transients 
    transient_left = transient_detector_func(left_signal, Fs);
    transient_left_samples = transient_left * Fs; 
    transient_right = transient_detector_func(right_signal, Fs); 
    transient_right_samples = transient_right * Fs; 

    % cut out only the 100 ms transient 
    transient_length = 0.1 * 44100; % 100ms length of samples
    left_signal = left_signal(transient_left_samples: ...
                        transient_length + transient_left_samples);
    right_signal = right_signal(transient_right_samples: ...
                        transient_right_samples + transient_length);

    power_left_channel = calculate_power(left_signal);
    power_right_channel = calculate_power(right_signal);

end


function ratio = distance_ratio(power1, power2)
    ratio = sqrt(power2 / power1);
end


function error = objective_function_rssi(source_pos, mics_upper, mics_lower, ceiling, distance_ratios)
    estimated_ratios = [];
    for ceil_idx = 1:length(ceiling)
        ceiling_mic = ceiling(ceil_idx, :);
        d_ceiling = norm(source_pos - ceiling_mic);

        for i = 1:length(mics_upper)
            mic_i_left = mics_upper(i).left;
            mic_i_right = mics_upper(i).right;
            mic_i_vert_left = mics_lower(i).left;
            mic_i_vert_right = mics_lower(i).right;
    
            for j = i+1:length(mics_upper)
                mic_j_left = mics_upper(j).left;
                mic_j_right = mics_upper(j).right;
    
                mic_j_vert_left = mics_lower(j).left;
                mic_j_vert_right = mics_lower(j).right;
                % Combine all pairs and calculate ratios
                d_i_left = norm(source_pos - mic_i_left);
                d_i_right = norm(source_pos - mic_i_right);
                d_j_left = norm(source_pos - mic_j_left);
                d_j_right = norm(source_pos - mic_j_right);
    
                d_i_vert_left = norm(source_pos - mic_i_vert_left);
                d_i_vert_right = norm(source_pos - mic_i_vert_right);
                d_j_vert_left = norm(source_pos - mic_j_vert_left);
                d_j_vert_right = norm(source_pos - mic_j_vert_right);
                ratios = [
                    d_i_left/ d_j_left, ...
                    d_i_left/ d_j_right, ...
                    d_i_right/ d_j_left, ...
                    d_i_right/ d_j_right, ...
                    d_i_vert_left/ d_j_vert_right, ...
                    d_i_vert_right/ d_j_vert_left, ...
                    d_i_right / d_j_vert_right, ...
                    d_ceiling / d_i_left, ...
                    d_ceiling / d_i_right, ...
                    d_ceiling / d_i_vert_left, ...
                    d_ceiling / d_i_vert_right, ...
                    d_ceiling / d_j_left, ...
                    d_ceiling / d_j_right, ...
                    d_ceiling / d_j_vert_left, ...
                    d_ceiling / d_j_vert_right, ...
                ];
    
                % Store the ratios in the variable
                estimated_ratios = [estimated_ratios; ratios];
            end
        end
    end

    error = sum((estimated_ratios - distance_ratios) .^ 2);
    error = sum(error .^ 2);
end
