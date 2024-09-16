function [transients_left, transients_right] = detect_transients(audio_dir)

    files = dir(fullfile('~', audio_dir, '*.wav'));
    channels = {'left', 'right'};

    if ~isempty(files)
        input_file = files(1).name;
        path = fullfile('~', audio_dir,input_file);
        [y, Fs] = audioread(path);

        y_mono = select_channel(y, 'left');
        fprintf("Časi pojavljanja zaznanih dogodkov v levem kanalu:\n");
        transients_left = transient_detector_func(y_mono, Fs)

        y_mono_right = select_channel(y,'right');
        fprintf("Časi pojavljanja zaznanih dogodkov v desnem kanalu:\n");
        transients_right = transient_detector_func(y_mono_right, Fs)
    end
end