function [cut_audio_segment, padded] = cut_audio_func(audio, fs, start_ms, length_ms)
    start_sample = round(start_ms / 1000 * fs) + 1;
    length_samples = round(length_ms / 1000 * fs);
    end_sample = start_sample + length_samples - 1;
    
    if end_sample > length(audio)
        padding_length = end_sample - length(audio);
        % Check if audio is mono or stereo
        if size(audio, 2) == 1
            silence = zeros(padding_length, 1); % mono
        else
            silence = zeros(padding_length, size(audio, 2)); % stereo
        end
        cut_audio_segment = [audio(start_sample:end, :); silence];
        padded = true;     
    else
        cut_audio_segment = audio(start_sample:end_sample, :); 
        padded = false;
    end
end