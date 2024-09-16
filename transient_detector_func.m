function filtered_times_of_transients = transient_detector_func(y, Fs)

    % adjustable parameters
    time_interval = 0.04; % 40 ms
    no_samples = time_interval * Fs; 
    no_samples = closestPowerOfTwo(no_samples);
    overlap_precentage = 0.75;
    overlap_samples = overlap_precentage * no_samples;
    N_bins = 7; 
    % over how many spectogram bins we will smooth the functions
    N_timeframes = 5; 
    % how many time frames are considered for the threshold calculation
    beta = 2.5; %eksp s hrupom: 2.9;%3.2-pleski, tloski, snaps; 
    % controls the strength of transients to be detected
    lamba_threshold = no_samples/6;
    window = blackmanharris(no_samples, 'periodic');
    
    % stft calculation
    y_norm = zeros(size(y));
    y_norm(:,1) = y(:,1)/max(y(:,1));

    [s_1,f_1,t_1] = stft(y_norm(:,1), Fs, ...
                            Window=window,OverlapLength=overlap_samples);
  
    % Filter out small frequencies ( 0 - 60 Hz) 
    indices_1 = f_1 >= -60 & f_1 <= 60; 
   
    s_1(indices_1,:) = 0; 

    magnitude_1 = abs(s_1);
 
    % T- and T+ functions - razlike med amplitudami skozi čas
    % For channel 1
    T_minus_1 = diff(magnitude_1, 1, 2);  
    T_plus_1 = -diff(magnitude_1(:, end:-1:1), 1, 2); 
    T_plus_1 = T_plus_1(:, end:-1:1);
    % Padding 
    T_plus_1 = [T_plus_1,zeros( size(T_plus_1, 1), 1)];
    T_minus_1 = [zeros(size(T_minus_1, 1), 1), T_minus_1];
  
    
    % sign funkcija glede na clanek ( razlika v 0 z MATLABom ! )
    sgn = @(x) double(x >= 0) - double(x < 0);
    [numBins, numFrames] = size(magnitude_1);
    
    % smoothed half wave rectified T functions -> F_function
    F_function_1 = zeros(numBins, numFrames);
    
    for i = 1 : numFrames
        for j = 1 : numBins
            kStart = max(1, j - N_bins);
            kEnd = min(numBins, j + N_bins);
    
            F_function_1(j, i) = 0.5 * sum( ...
                (1 + sgn(T_minus_1(kStart:kEnd, i) ) ).* T_minus_1(kStart:kEnd, i) ...
                + (1 + sgn(T_plus_1(kStart:kEnd, i) ) ).* T_plus_1(kStart:kEnd, i) );
        end
    end 
    
    % adaptive threshold calculation; weakness: goes into the future
    % (i+N_timeframes)
    thresholds = zeros(numBins, numFrames);
    
    for i = 1 : numFrames
        for j = 1: numBins
            lStart = max(1, i - N_timeframes);
            lEnd = min(numFrames, i + N_timeframes);
            
            thresholds(j, i) = beta / (2 * N_timeframes + 1) * ...
                                sum(F_function_1(j, lStart:lEnd));
        end
    end
    
    gama_flags = zeros(numBins, numFrames);
    
    for i = 1: numFrames
        for j = 1: numBins
            if( F_function_1(j, i) > thresholds(j, i))
                gama_flags(j, i) = 1;
            else 
                gama_flags(j, i) = 0;
            end
        end
    end
    
    gama_sum = zeros(numFrames);
    
    gama_sum = sum(gama_flags, 1);
    
    indices_of_transient = find(gama_sum > lamba_threshold);
    
    times_of_transients = t_1(indices_of_transient);
    steps = diff(times_of_transients); 
    
    % now filter out the detected transient times, that are too close to
    % each other and belong to the same event. These moments are not more
    % than 0.1 ms apart.
    if ~isempty(times_of_transients)
        filtered_times_of_transients = [times_of_transients(1)];
        filtered_idx = 1;
        
        for idx= 2:1:length(steps)
            if (steps(idx) < 0.1 && (steps(idx) - filtered_times_of_transients(filtered_idx)) < 0.1)
                continue;
            else 
                filtered_idx = filtered_idx + 1;
                filtered_times_of_transients(filtered_idx) = times_of_transients(idx+1);
            end 
        end
    else
        filtered_times_of_transients = [];
        fprintf("No transients found!\n");
    end

end 