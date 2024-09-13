
function plot_geometry_of_aoa(theta_deg)
    % Constants
    c = 343;       % Speed of sound in air (m/s)
    baseline = 1;  % Distance between the microphones (m)

    theta_rad = deg2rad(theta_deg);

    % Calculate the time delay and distance difference based on theta
    distance_diff = baseline * cos(theta_rad);
    time_delay = distance_diff / c;

    % Display the results
    fprintf('The distance difference between the two signals is %.6f meters.\n', distance_diff);
    fprintf('The time delay between the two signals is %.6f seconds.\n', time_delay);

    % Geometry for visualization
    d = 1;  % Baseline distance in meters

    % Coordinates for the microphones
    mic1 = [-d/2, 0];  % Left microphone
    mic2 = [d/2, 0];   % Right microphone

    % Direction of the sound source
    source_direction = [cos(theta_rad), sin(theta_rad)];

    % Source point
    source_point = [cos(theta_rad), sin(theta_rad)] * 2;  % Extend the line for better visualization

    % Plot the geometry
    figure;
    hold on;
    % Plot microphones
    plot([mic1(1), mic2(1)], [mic1(2), mic2(2)], 'ko-', 'LineWidth', 2, 'MarkerSize', 10);

    % Plot source direction
    quiver(0, 0, source_direction(1), source_direction(2), 2, 'r', 'LineWidth', 2); 

    % Plot the lines connecting the source to the microphones
    plot([mic1(1), source_point(1)], [mic1(2), source_point(2)], 'b--');
    plot([mic2(1), source_point(1)], [mic2(2), source_point(2)], 'b--');

    % Annotate the microphones
    text(mic1(1), mic1(2), 'Mic 1', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
    text(mic2(1), mic2(2), 'Mic 2', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');

    % Annotate the source
    text(source_point(1), source_point(2), 'Sound Source', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');

    % Annotate the angle theta
    theta_label_pos = 0.5 * [cos(theta_rad), sin(theta_rad)];
    text(theta_label_pos(1), theta_label_pos(2), sprintf('\\theta = %.2f°', theta_deg), 'Color', 'r');

    % Highlight the angle
    theta_arc_x = cos(linspace(0, theta_rad, 100));
    theta_arc_y = sin(linspace(0, theta_rad, 100));
    plot(theta_arc_x, theta_arc_y, 'r-', 'LineWidth', 1.5);

    xlabel('X (meters)');
    ylabel('Y (meters)');
    title('Geometry of the Angle of Arrival');
    axis equal;
    grid on;
    hold off;

    % Pause execution and wait for a button press
    % disp('Press any key or click the mouse to continue...');
    % waitforbuttonpress;

   end
