function delay = process_files_gcc_phat(basedir_left, basedir_right, file_idx, lag_range)
    % Process files in the given directories
    files_left = dir(fullfile(basedir_left, '*.wav'));
    files_right = dir(fullfile(basedir_right, '*.wav'));

    if length(files_left) < file_idx || length(files_right) < file_idx
        warning('File index exceeds the number of available files in the directories.');
        delay = NaN;
        return;
    end

    file_path_left = fullfile(basedir_left, files_left(file_idx).name);
    file_path_right = fullfile(basedir_right, files_right(file_idx).name);

    try
        [y_left, Fs_left] = audioread(file_path_left);
        [y_right, Fs_right] = audioread(file_path_right);
    catch
        warning('Error reading file: %s or %s', files_left(file_idx).name, files_right(file_idx).name);
        delay = NaN;
        return;
    end

    % Apply GCC-PHAT
    [delay_samples, delay] = gcc_phat_ssl(y_left, y_right, Fs_left, lag_range);

    % Print results
    % fprintf('File: %s and %s\n', files_left(file_idx).name, files_right(file_idx).name);
    % fprintf('  Delay (samples): %d\n', delay_samples);
    % fprintf('  Delay (time): %.6f s\n', delay);
end