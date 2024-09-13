%% A transient detection algorithm for audio using STFT - test on one file

% input audio data
[y, Fs] = audioread('/home/eminaf/timestamped_audio_data/audio_file_1_synced_filtered_10claps.wav');

% Ensure the audio data is single-channel
if ~isvector(y)
    y_mono = y(:,2); % take the second channel, no sound artifacts
end


% y must be monochannel and Fs should be 44.1kHz
transients = transient_detector_func(y_mono, Fs)

%% 
beep_start = transients(1);
beep_start_samples = round(beep_start * Fs);

adjusted_audio_mono = y_mono(beep_start_samples:end);


% input audio data
[y_2, Fs] = audioread('/home/eminaf/timestamped_audio_data/audio_file_2_synced_filtered_10claps.wav');
targetFs = 44100;
% Ensure the audio data is single-channel
if ~isvector(y_2)
    y_mono_2 = y_2(:,2); % take the second channel, no sound artifacts
end


adjusted_audio_mono_2 = y_mono_2(beep_start_samples:end);

%skrajšati drugi signal na dolžino prvega, ker je program prekinjen rahlo
%kasneje 
adjusted_audio_mono_2 = adjusted_audio_mono_2(1:length(adjusted_audio_mono));

%vzemimo prvih 50 ms
ms15_samples = round(0.05 * Fs);
delay_samples = gcc_phat(adjusted_audio_mono(1:ms15_samples), adjusted_audio_mono_2(1:ms15_samples))
% gcc_phat vrne koliko prvi argument zamuja za drugim
delay = delay_samples/Fs % [s]

% Plot the signals for visual verification
figure;
subplot(2, 1, 1);
plot(adjusted_audio_mono);
title('Audio Signal 1 after transient detection');

subplot(2, 1, 2);
plot(adjusted_audio_mono_2);
title('Audio Signal 2 after transient detection');

%%

final_audio_1 = y(beep_start_samples:end,:);
final_audio_2 = y_2(beep_start_samples:end,:);
final_audio_2 = final_audio_2(1:length(final_audio_1),:);

if delay_samples < 0 % drugi signal iz funkcije zamuja za prvim
    final_audio_2 = final_audio_2(abs(delay_samples):end,:);
    final_audio_1 = final_audio_1(1:length(final_audio_2),:);
  
elseif delay_samples > 0 % prvi signal zamuja za drugim
    final_audio_1 = final_audio_1(abs(delay_samples):end,:);
    final_audio_2 = final_audio_2(1:length(final_audio_1),:);
else
    fprintf("No delay, files are aligned. ");
end

audiowrite('/home/eminaf/timestamped_audio_data/matlab_sync_1_10claps.wav', final_audio_1, Fs);
audiowrite('/home/eminaf/timestamped_audio_data/matlab_sync_2_10claps.wav', final_audio_2, Fs);
