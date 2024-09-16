function ssl_clap_automated_experiment_more_mics(audio_dir)
   

    %base_dir = fullfile('/home/eminaf/experiment_data', timestamp_folder);
    mic_dirs = dir(fullfile('~', audio_dir, 'mic_*'));
    files = dir(fullfile(audio_dir, '*.wav'));
    channels = {'left', 'right'};
    channels_add = {'left', 'right', 'channel3', 'channel4'};
    % velja samo za mikrofone na stropu
    cut_length_ms = 200;

    % detektiraj tranziente v prvi datoteki, da pridobiš štartne čase
    % dogodkov
    file_name = 'audio_file_1_synced_filt.wav';
    input_file = fullfile(audio_dir, file_name);
    [y, Fs] = audioread(input_file);
    y_mono = select_channel(y, 'left');
    fprintf("Časi pojavljanja zaznanih dogodkov:\n");
    transients = transient_detector_func(y_mono, Fs)
    % po potrebi filtriraj napačno detektirane tranziente
    transients = transients(1:end); 
    start_points = (transients) * 1000 - 30; % *1000 s->ms

    for mic_idx = 1:length(mic_dirs)
        mic_dir = mic_dirs(mic_idx).name

        input_file = fullfile(audio_dir, files(mic_idx).name);
         
        [y, Fs] = audioread(input_file);
       
        % izloči posamezne dogodke v vsakem kanalu
        if mic_idx == 1
           for ch_idx = 1:length(channels_add)
                channel = channels_add{ch_idx};
                output_dir = fullfile(audio_dir, mic_dir, sprintf("%s_channel",channel))
                if ~exist(output_dir, 'dir')
                    mkdir(output_dir);
                end
                y_channel = select_channel(y, channel);
                process_transients(y_channel, Fs, start_points, cut_length_ms, output_dir);
            end
        else 
            for ch_idx = 1:length(channels)
                channel = channels{ch_idx};
                output_dir = fullfile(audio_dir, mic_dir, sprintf("%s_channel",channel))
                if ~exist(output_dir, 'dir')
                    mkdir(output_dir);
                end
                y_channel = select_channel(y, channel);
                process_transients(y_channel, Fs, start_points, cut_length_ms, output_dir);
            end
        end
        

    end
end