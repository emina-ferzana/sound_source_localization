function y_channel = select_channel(y, channel)
    % Select the appropriate channel from the audio file
    switch channel
        case 'left'
            y_channel = y(:, 1);
        case 'right'
            y_channel = y(:, 2);
        case 'channel3'
            if size(y, 2) >= 3
                y_channel = y(:, 3);
            else
                y_channel = [];
            end
        case 'channel4'
            if size(y, 2) >= 4
                y_channel = y(:, 4);
            else
                y_channel = [];
            end
        otherwise
            error('Unknown channel specified');
    end
end