function [delay_samples, delay] = gcc_phat_ssl(y_left, y_right, Fs, lag_range)
    
    % Apply GCC-PHAT to calculate the delay between two signals

    nfft = 2^nextpow2(length(y_right) + length(y_left) - 1);
    Y_right = fft(y_right, nfft);
    Y_left = fft(y_left, nfft);

    % Cross-power spectrum
    R = Y_left .* conj(Y_right);

    % Normalize cross-power spectrum (PHAT)
    R = R ./ abs(R);

    % Inverse FFT to obtain cross-correlation
    cc = ifft(R);

    % Create the lags vector
    lags = -floor(nfft/2):floor(nfft/2)-1;

    % Shift the result to zero-center the correlation
    cc = fftshift(cc);

    % Define the lag range of interest (assuming Fs = 44.1 kHz and max delay of 15 ms)
    lag_indices = find(lags >= -lag_range & lags <= lag_range);

    % Limit the cross-correlation and lags to the specified range
    cc_limited = cc(lag_indices);
    lags_limited = lags(lag_indices);

    % Find the index of the maximum correlation within the limited range
    [~, idx_limited] = max(abs(cc_limited));
    delay_samples = lags_limited(idx_limited);

    % Convert the lag to time
    delay = delay_samples / Fs;
    
end