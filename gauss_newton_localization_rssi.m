function [loc_source_est, residuals] = ...
                gauss_newton_localization_rssi(mics_upper, mics_lower, ...
                                            ceiling, idx_file, audio_dir, ...
                                            loc_source_init, max_iter, tol)

    loc_source_est = loc_source_init;
    
    channels_add = {'left_channel', 'right_channel', 'channel3_channel', 'channel4_channel'};
    [power_upper, power_lower, power_ceiling] = calculate_all_powers(mics_upper, mics_lower, ceiling, channels_add, audio_dir, idx_file);

    residuals = [];

    for iter = 1:max_iter

        f = [];
        J = [];
        
        measured_ratios = get_meas_ratios(power_ceiling, power_upper, power_lower);
        [estimated_ratios, J] = get_est_ratios(loc_source_est, mics_upper, mics_lower, ceiling);
        
        for i = 1:length(measured_ratios)
            rat_meas = measured_ratios(i);
            rat_est = estimated_ratios(i);

            % Residual
            f = [f; rat_est - rat_meas];            
        end
    

        % posodobi oceno položaja vira zvoka
        delta = -pinv(J' * J) * J' * f;
        
        loc_source_est = loc_source_est + delta';

        % shrani normo residuala
        f = norm(f);
        residuals = [residuals; f];

        % ali je izpoljneno pogoj za konvergenco?
        if norm(delta) < tol
            break;
        end
    end
end


function [power_upper, power_lower, power_ceiling] = calculate_all_powers(mics_upper, mics_lower, ceiling, channels_add, audio_dir, idx_file)
    
    power_ceiling = zeros(length(ceiling),1);
    for ceil_idx = 1:length(ceiling)
        power_ceiling(ceil_idx) = extract_transient_and_calculate_power_ceiling_mic...
                (audio_dir, channels_add{ceil_idx}, idx_file);
    end

    power_upper = zeros(length(mics_upper),2); %Mics 1,3,5,7
    power_lower = zeros(length(mics_lower),2); %Mics 2,4,6,8
    for upper_idx = 1:length(mics_upper)
        % Read the files for Mic i
        idx_mic_i = (upper_idx - 1) * 2 + 1; % Calculate the microphone index for i
        idx_mic_vert_i = 2 * upper_idx; % equivalent to mics_lower

        [power_upper(upper_idx, 1), power_upper(upper_idx,2)] = extract_transient_and_calculate_power(audio_dir, idx_mic_i, idx_file);
        [power_lower(upper_idx, 1), power_lower(upper_idx,2)] = extract_transient_and_calculate_power(audio_dir, idx_mic_vert_i, idx_file);

    end
end


function measured_ratios = get_meas_ratios(pow_ceiling, pow_upper, pow_lower)
    measured_ratios = [];
    for ceil_idx = 1:length(pow_ceiling)
            power_ceiling_mic = pow_ceiling(ceil_idx);
            for i = 1:size(pow_upper,1)
                
                % [power_left_i, power_right_i] = pow_upper(i,:); % iz
                % nekega razloga ne dela
                power_left_i = pow_upper(i,1);
                power_right_i = pow_upper(i,2);
                % [power_left_vert_i, power_right_vert_i] = pow_lower(i,:);
                power_left_vert_i = pow_lower(i,1);
                power_right_vert_i = pow_lower(i,2);
               
                for j = i+1:size(pow_upper,1)    
                   
                    %[power_left_j, power_right_j] = pow_upper(j,:);   
                    power_left_j = pow_upper(j,1);
                    power_right_j = pow_upper(j,2);

                    % Do that for the vertical pairs (mics_lower)
                    %[power_left_vert_j, power_right_vert_j] = pow_lower(j,:);
                    power_left_vert_j = pow_lower(j,1);
                    power_right_vert_j = pow_lower(j,2);
                    
                    % Combine all relevant pairs and calculate ratios
                    ratios = [
                        distance_ratio(power_left_i, power_left_j), ...
                        distance_ratio(power_left_i, power_right_j), ...
                        distance_ratio(power_right_i, power_left_j), ...
                        distance_ratio(power_right_i, power_right_j), ...
                        distance_ratio(power_left_vert_i, power_right_vert_j), ...
                        distance_ratio(power_right_vert_i, power_left_vert_j), ...
                        distance_ratio(power_right_i, power_right_vert_j), ...
                        distance_ratio(power_ceiling_mic, power_left_i), ...
                        distance_ratio(power_ceiling_mic, power_right_i), ...
                        distance_ratio(power_ceiling_mic, power_left_vert_i), ...
                        distance_ratio(power_ceiling_mic, power_right_vert_i), ...
                        distance_ratio(power_ceiling_mic, power_left_j), ...
                        distance_ratio(power_ceiling_mic, power_right_j), ...
                        distance_ratio(power_ceiling_mic, power_left_vert_j), ...
                        distance_ratio(power_ceiling_mic, power_right_vert_j)
                    ];
        
                    % Store the ratios in the variable
                    measured_ratios = [measured_ratios, ratios];
                end
            end
    end
end

function [estimated_ratios, Jacobian] = get_est_ratios(source_pos, mics_upper, mics_lower, ceiling)
    estimated_ratios = [];
    Jacobian = [];
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
                Jx = [((source_pos(1)-mic_i_left(1))/d_i_left) * d_j_left - d_i_left * (source_pos(1) - mic_j_left(1))/d_j_left; ...
                        ((source_pos(1)-mic_i_left(1))/d_i_left) * d_j_right - d_i_left * (source_pos(1) - mic_j_right(1))/d_j_right; ...
                        ((source_pos(1)-mic_i_right(1))/d_i_right) * d_j_left - d_i_right * (source_pos(1) - mic_j_left(1))/d_j_left; ...
                        ((source_pos(1)-mic_i_right(1))/d_i_right) * d_j_right - d_i_right * (source_pos(1) - mic_j_right(1))/d_j_right; ...
                        ((source_pos(1)-mic_i_vert_left(1))/d_i_vert_left) * d_j_vert_right - d_i_vert_left * (source_pos(1) - mic_j_vert_right(1))/d_j_vert_right; ...
                        ((source_pos(1)-mic_i_vert_right(1))/d_i_vert_right) * d_j_vert_left - d_i_vert_right * (source_pos(1) - mic_j_vert_left(1))/d_j_vert_left; ...
                        ((source_pos(1)-mic_i_right(1))/d_i_right) * d_j_vert_right - d_i_right * (source_pos(1) - mic_j_vert_right(1))/d_j_vert_right; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_i_left - d_ceiling * (source_pos(1) - mic_i_left(1))/d_i_left; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_i_right - d_ceiling * (source_pos(1) - mic_i_right(1))/d_i_right; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_i_vert_left - d_ceiling * (source_pos(1) - mic_i_vert_left(1))/d_i_vert_left; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_i_vert_right - d_ceiling * (source_pos(1) - mic_i_vert_right(1))/d_i_vert_right; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_j_left - d_ceiling * (source_pos(1) - mic_j_left(1))/d_j_left; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_j_right - d_ceiling * (source_pos(1) - mic_j_right(1))/d_j_right; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_j_vert_left - d_ceiling * (source_pos(1) - mic_j_vert_left(1))/d_j_vert_left; ...
                        ((source_pos(1)-ceiling_mic(1))/d_ceiling) * d_j_vert_right - d_ceiling * (source_pos(1) - mic_j_vert_right(1))/d_j_vert_right
                        ];
                Jy = [((source_pos(2)-mic_i_left(2))/d_i_left) * d_j_left - d_i_left * (source_pos(2) - mic_j_left(2))/d_j_left; ...
                        ((source_pos(2)-mic_i_left(2))/d_i_left) * d_j_right - d_i_left * (source_pos(2) - mic_j_right(2))/d_j_right; ...
                        ((source_pos(2)-mic_i_right(2))/d_i_right) * d_j_left - d_i_right * (source_pos(2) - mic_j_left(2))/d_j_left; ...
                        ((source_pos(2)-mic_i_right(2))/d_i_right) * d_j_right - d_i_right * (source_pos(2) - mic_j_right(2))/d_j_right; ...
                        ((source_pos(2)-mic_i_vert_left(2))/d_i_vert_left) * d_j_vert_right - d_i_vert_left * (source_pos(2) - mic_j_vert_right(2))/d_j_vert_right; ...
                        ((source_pos(2)-mic_i_vert_right(2))/d_i_vert_right) * d_j_vert_left - d_i_vert_right * (source_pos(2) - mic_j_vert_left(2))/d_j_vert_left; ...
                        ((source_pos(2)-mic_i_right(2))/d_i_right) * d_j_vert_right - d_i_right * (source_pos(2) - mic_j_vert_right(2))/d_j_vert_right; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_i_left - d_ceiling * (source_pos(2) - mic_i_left(2))/d_i_left; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_i_right - d_ceiling * (source_pos(2) - mic_i_right(2))/d_i_right; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_i_vert_left - d_ceiling * (source_pos(2) - mic_i_vert_left(2))/d_i_vert_left; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_i_vert_right - d_ceiling * (source_pos(2) - mic_i_vert_right(2))/d_i_vert_right; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_j_left - d_ceiling * (source_pos(2) - mic_j_left(2))/d_j_left; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_j_right - d_ceiling * (source_pos(2) - mic_j_right(2))/d_j_right; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_j_vert_left - d_ceiling * (source_pos(2) - mic_j_vert_left(2))/d_j_vert_left; ...
                        ((source_pos(2)-ceiling_mic(2))/d_ceiling) * d_j_vert_right - d_ceiling * (source_pos(2) - mic_j_vert_right(2))/d_j_vert_right
                        ];
                Jz = [((source_pos(3)-mic_i_left(3))/d_i_left) * d_j_left - d_i_left * (source_pos(3) - mic_j_left(3))/d_j_left; ...
                        ((source_pos(3)-mic_i_left(3))/d_i_left) * d_j_right - d_i_left * (source_pos(3) - mic_j_right(3))/d_j_right; ...
                        ((source_pos(3)-mic_i_right(3))/d_i_right) * d_j_left - d_i_right * (source_pos(3) - mic_j_left(3))/d_j_left; ...
                        ((source_pos(3)-mic_i_right(3))/d_i_right) * d_j_right - d_i_right * (source_pos(3) - mic_j_right(3))/d_j_right; ...
                        ((source_pos(3)-mic_i_vert_left(3))/d_i_vert_left) * d_j_vert_right - d_i_vert_left * (source_pos(3) - mic_j_vert_right(3))/d_j_vert_right; ...
                        ((source_pos(3)-mic_i_vert_right(3))/d_i_vert_right) * d_j_vert_left - d_i_vert_right * (source_pos(3) - mic_j_vert_left(3))/d_j_vert_left; ...
                        ((source_pos(3)-mic_i_right(3))/d_i_right) * d_j_vert_right - d_i_right * (source_pos(3) - mic_j_vert_right(3))/d_j_vert_right; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_i_left - d_ceiling * (source_pos(3) - mic_i_left(3))/d_i_left; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_i_right - d_ceiling * (source_pos(3) - mic_i_right(3))/d_i_right; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_i_vert_left - d_ceiling * (source_pos(3) - mic_i_vert_left(3))/d_i_vert_left; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_i_vert_right - d_ceiling * (source_pos(3) - mic_i_vert_right(3))/d_i_vert_right; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_j_left - d_ceiling * (source_pos(3) - mic_j_left(3))/d_j_left; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_j_right - d_ceiling * (source_pos(3) - mic_j_right(3))/d_j_right; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_j_vert_left - d_ceiling * (source_pos(3) - mic_j_vert_left(3))/d_j_vert_left; ...
                        ((source_pos(3)-ceiling_mic(3))/d_ceiling) * d_j_vert_right - d_ceiling * (source_pos(3) - mic_j_vert_right(3))/d_j_vert_right
                        ];
                % Store the ratios in the variable
                
                Jacobian = [Jacobian; Jx Jy Jz];
                estimated_ratios = [estimated_ratios, ratios];
            end
        end
    end
end

function [power_left_channel, power_right_channel] = ...
    extract_transient_and_calculate_power(audio_dir, mic_index, file_index)


    left_dir = fullfile(audio_dir, ['mic_', num2str(mic_index)], 'left_channel');
    right_dir = fullfile(audio_dir, ['mic_', num2str(mic_index)], 'right_channel');
    
    left_files = dir(fullfile(left_dir, '*.wav'));
    right_files = dir(fullfile(right_dir, '*.wav'));
    
    file_left = fullfile(left_dir, left_files(file_index).name);
    file_right = fullfile(right_dir, right_files(file_index).name);
    
    [left_signal, Fs] = audioread(file_left);
    [right_signal, Fs] = audioread(file_right);
   
    % Find transients 
    transient_left = transient_detector_func(left_signal, Fs);  
    transient_right = transient_detector_func(right_signal, Fs); 

    if ~isempty(transient_left) && ~isempty(transient_right)

        transient_left_samples = transient_left * Fs; 
        transient_right_samples = transient_right * Fs; 
    
        % Cut out only the 100 ms transient 
        transient_length = 0.1 * 44100; % 100ms length of samples
        left_signal = left_signal(transient_left_samples: ...
                            transient_length + transient_left_samples);
        right_signal = right_signal(transient_right_samples: ...
                            transient_right_samples + transient_length);
    
        power_left_channel = calculate_power(left_signal);
        power_right_channel = calculate_power(right_signal);

    else
        fprintf("%s %s\n", file_left, file_right);
        error("No transients found! The localization cannot continue." + ...
            "Try with some other recordings.\n"); 
        

    end
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


function power = calculate_power(signal)
    signal = signal - mean(signal);
    power = mean(signal .^ 2);
end

function ratio = distance_ratio(power1, power2)
    ratio = sqrt(power2 / power1);
end