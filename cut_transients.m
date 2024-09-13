function cut_transients(input_file, Fs, start_points, cut_length_ms, output_dir)
    [y_filtered, Fs] = audioread(input_file);
    for idx = 1:length(start_points)
        [cut_audio_segment, padded] = cut_audio_func(y_filtered, Fs, start_points(idx), cut_length_ms);
        new_file_name = sprintf('event_%.2f.wav', start_points(idx));

        if padded
            new_file_name = strrep(new_file_name, '.wav', '_padded.wav');
        end

        output_path = fullfile(output_dir, new_file_name);
        if exist(output_path, 'file')
            fprintf('File already exists, skipping: %s\n', output_path);
            continue;
        end
        audiowrite(output_path, cut_audio_segment, Fs);
    end
end