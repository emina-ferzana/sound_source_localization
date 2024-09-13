function plot_all_mics(horizontal_angles, vertical_angles, horizontal_std, vertical_std)

    mic_positions = {
        [0, 0, 0], [1.02, 0, 0];           % Mic 1 (horizontal)
        [0, 0, 0], [0, 0, 1.02];           % Mic 2 (vertical)
        [4.06, 0.22, 0], [5.05, 0.22, 0];        % Mic 3 (horizontal)
        [4.06, 0.22, 0], [4.03, 0.22, 1.02];     % Mic 4 (vertical)
        [0.62, 6.34, 0], [-0.4, 6.34, 0]; % Mic 5 (horizontal)
        [0.62, 6.34, 0], [0.62, 6.34, 1.02]; % Mic 6 (vertical)
        [4.36, 6.34, -0.22], [3.34, 6.34, -0.22]; % Mic 7 (horizontal)
        [4.36, 6.34, -0.22], [4.36, 6.34, 0.79];  % Mic 8 (vertical)
    };

    source = [2.9,3,1.24];
    % Plot the source and microphone points
    figure;
    hold on;
    grid on;
    axis equal;
    
    plot3(source(1), source(2), source(3), 'go', 'MarkerFaceColor', 'g');

    % Plot each mic pair
    for i = 1:length(mic_positions)
        mic_left = mic_positions{i, 1};
        mic_right = mic_positions{i, 2};
        
        % Plot the microphone points
        plot3(mic_left(1), mic_left(2), mic_left(3), 'ro', 'MarkerFaceColor', 'r');
        plot3(mic_right(1), mic_right(2), mic_right(3), 'ro', 'MarkerFaceColor', 'r');

        % Connect the microphones in the pair
        plot3([mic_left(1), mic_right(1)], [mic_left(2), mic_right(2)], [mic_left(3), mic_right(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    end
    
    % Additional connections to form frames
    % Frame 1 connections    
    text(mic_positions{1, 1}(1),mic_positions{1, 1}(2),mic_positions{1, 1}(3), 'Frame 1', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    plot3([mic_positions{1,1}(1), mic_positions{2,2}(1)], [mic_positions{1,1}(2), mic_positions{2,2}(2)], [mic_positions{1,1}(3), mic_positions{2,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{1,2}(1), mic_positions{2,1}(1)], [mic_positions{1,2}(2), mic_positions{2,1}(2)], [mic_positions{1,2}(3), mic_positions{2,1}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{1,2}(1), mic_positions{1,2}(1)], [mic_positions{1,2}(2), 0], [mic_positions{1,2}(3), mic_positions{2,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{2,2}(1), mic_positions{1,2}(1)], [mic_positions{2,2}(2), 0], [mic_positions{2,2}(3), mic_positions{2,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);

    % Frame 2 connections
    text(mic_positions{3, 1}(1),mic_positions{3, 1}(2),mic_positions{3, 1}(3), 'Frame 2', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    plot3([mic_positions{3,1}(1), mic_positions{4,2}(1)], [mic_positions{3,1}(2), mic_positions{4,2}(2)], [mic_positions{3,1}(3), mic_positions{4,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{3,2}(1), mic_positions{4,1}(1)], [mic_positions{3,2}(2), mic_positions{4,1}(2)], [mic_positions{3,2}(3), mic_positions{4,1}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{3,2}(1), mic_positions{3,2}(1)], [mic_positions{3,2}(2), 0.22], [mic_positions{3,2}(3), mic_positions{4,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{4,2}(1), mic_positions{3,2}(1)], [mic_positions{4,2}(2), 0.22], [mic_positions{4,2}(3), mic_positions{4,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);

    % Frame 3 connections
    text(mic_positions{5, 1}(1),mic_positions{5, 1}(2),mic_positions{5, 1}(3), 'Frame 3', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');    
    plot3([mic_positions{5,1}(1), mic_positions{6,2}(1)], [mic_positions{5,1}(2), mic_positions{6,2}(2)], [mic_positions{5,1}(3), mic_positions{6,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{5,2}(1), mic_positions{6,1}(1)], [mic_positions{5,2}(2), mic_positions{6,1}(2)], [mic_positions{5,2}(3), mic_positions{6,1}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{5,2}(1), mic_positions{5,2}(1)], [mic_positions{5,2}(2), mic_positions{5,2}(2)], [mic_positions{5,2}(3), mic_positions{6,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{6,2}(1), mic_positions{5,2}(1)], [mic_positions{6,2}(2), mic_positions{5,2}(2)], [mic_positions{6,2}(3), mic_positions{6,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);

    % Frame 4 connections
    text(mic_positions{7, 1}(1),mic_positions{7, 1}(2),mic_positions{7, 1}(3), 'Frame 4', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    plot3([mic_positions{7,1}(1), mic_positions{8,2}(1)], [mic_positions{7,1}(2), mic_positions{8,2}(2)], [mic_positions{7,1}(3), mic_positions{8,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{7,2}(1), mic_positions{8,1}(1)], [mic_positions{7,2}(2), mic_positions{8,1}(2)], [mic_positions{7,2}(3), mic_positions{8,1}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{7,2}(1), mic_positions{7,2}(1)], [mic_positions{7,2}(2), mic_positions{7,2}(2)], [mic_positions{7,2}(3), mic_positions{8,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    plot3([mic_positions{8,2}(1), mic_positions{7,2}(1)], [mic_positions{8,2}(2), mic_positions{7,2}(2)], [mic_positions{8,2}(3), mic_positions{8,2}(3)], 'k--', 'LineWidth', 0.5, 'Color', [0, 0, 0, 0.5]);
    % srediscne tocke vseh okvirjev
    P0 = {[0.5; 0; 0.5];
            [4.5; 0; 0.5];
            [0.1; 6.34; 0.5];
            [3.85; 6.34; 0.29]};
    % Plot lines of intersection based on AoA estimations
    for i = 1:length(mic_positions)/2
        % Get the angles in radians
        theta_V = deg2rad(vertical_angles(2*i));
        if i>2
            theta_V = theta_V*-1;
        end
        theta_H = deg2rad(horizontal_angles(2*i -1));
        
        % Define normal vectors for the planes
        nV = [0; cos(theta_V); -sin(theta_V)];
        nH = [-sin(theta_H); cos(theta_H); 0];
        
        % Calculate the direction vector of the line of intersection
        d = cross(nV, nH);
        
        % Assume the line passes through the center of the frame
        center_point = P0{i};
        
        % Define a range for the parameter t to plot the line
        t = linspace(-5, 5, 100);
        
        % Calculate points on the line of intersection
        line_points = center_point + d * t;
        
        % Plot the line of intersection
        plot3(line_points(1, :), line_points(2, :), line_points(3, :), 'k', 'LineWidth', 1.2);
    end

    % Set labels and title
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('Intersection of AoA estimations');

    % Adjust axis directions
    set(gca, 'XDir', 'normal'); % x-axis to the right
    set(gca, 'YDir', 'reverse'); % y-axis towards the observer
    set(gca, 'ZDir', 'reverse'); % z-axis down

    view(3); % Set the view to 3D

    get_GT(mic_positions, source, horizontal_angles, vertical_angles, horizontal_std, vertical_std)
    hold off;
end

function get_GT(mic_positions, src_pos, horizontal_angles, vertical_angles, std_values_horizontal, std_values_vertical)
    middle_points = zeros(size(mic_positions,1),3);
    for i = 1:size(mic_positions,1)
        mic1= mic_positions{i,1};
        mic2= mic_positions{i,2};
        middle_points(i,:) = mean([mic1;mic2]);
    end

    fprintf("NOTE: The following ground truth values are only valid for source positions \n" + ...
        " in the range x = [0.51,4.55], y=[0,6.34], z=[0.51, 4 (the floor of the room is the limit)]\n");
    
    % Okvir 1
    aoa_h = rad2deg(atan((src_pos(2) - middle_points(1,2)) / ...
        (src_pos(1)-middle_points(1,1)) ) );
    aoa_v = rad2deg(atan((src_pos(2) - middle_points(2,2)) / ...
        (src_pos(3)-middle_points(2,3))));
    fprintf("\n");
    fprintf("Ground truth for AOA sensor 1 \n AOA vertical: %f \n" + ...
        "AOA horizontal: %f \n", aoa_v, aoa_h);
    fprintf("Measured: \n AOA vertical: %f +- %f\n AOA horizontal: %f +- %f", ...
        vertical_angles(2), std_values_vertical(2), ...
        horizontal_angles(1), std_values_horizontal(1));
    fprintf("\n");

    % Okvir 2
    aoa_h = 180 - rad2deg(atan(abs(src_pos(2) - middle_points(3,2)) / ...
        abs(src_pos(1)-middle_points(3,1)) ) );
    aoa_v = rad2deg(atan((src_pos(2) - middle_points(4,2)) / ...
        (src_pos(3)-middle_points(4,3))));
    fprintf("\n");
    fprintf("Ground truth for AOA sensor 2 \n AOA vertical: %f \n" + ...
        "AOA horizontal: %f \n", aoa_v, aoa_h);
    fprintf("Measured: \n AOA vertical: %f +- %f\n AOA horizontal: %f +- %f", ...
        vertical_angles(4), std_values_vertical(4), ...
        horizontal_angles(3), std_values_horizontal(3));
    fprintf("\n");

    % Okvir 3
    aoa_h = 90 + rad2deg(atan(abs(src_pos(1) - middle_points(5,1)) / ...
        abs(src_pos(2)-middle_points(5,2)) ) );
    aoa_v = rad2deg(atan(abs(src_pos(2) - middle_points(6,2)) / ...
        abs(src_pos(3)-middle_points(6,3))));
    fprintf("\n");
    fprintf("Ground truth for AOA sensor 3 \n AOA vertical: %f \n" + ...
        "AOA horizontal: %f \n", aoa_v, aoa_h);
    fprintf("Measured: \n AOA vertical: %f +- %f\n AOA horizontal: %f +- %f", ...
        vertical_angles(6), std_values_vertical(6), ...
        horizontal_angles(5), std_values_horizontal(5));
    fprintf("\n");

    % Okvir 4
    aoa_h = rad2deg(atan(abs(src_pos(2) - middle_points(7,2)) / ...
        abs(src_pos(1)-middle_points(7,1)) ) );
    aoa_v = rad2deg(atan(abs(src_pos(2) - middle_points(8,2)) / ...
        abs(src_pos(3)-middle_points(8,3))));
    fprintf("\n");
    fprintf("Ground truth for AOA sensor 4 \n AOA vertical: %f \n" + ...
        "AOA horizontal: %f \n", aoa_v, aoa_h);
    fprintf("Measured: \n AOA vertical: %f +- %f\n AOA horizontal: %f +- %f", ...
        vertical_angles(8), std_values_vertical(8), ...
        horizontal_angles(7), std_values_horizontal(7));
    fprintf("\n");
end 
