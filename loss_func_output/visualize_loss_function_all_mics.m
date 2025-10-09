%% visualize the loss function values over the entire room

% initialize the room as a grid
room_width = 6;
room_length = 7;
room_height = 4;
grid_el = 0.25;

% list all files
mat_file_dir = 'loss_func_output/20240805145919';
all_mat_files = dir(fullfile(mat_file_dir, '*.mat'));

[x, y, z] = ndgrid(grid_el/2:grid_el:room_width-grid_el/2, grid_el/2:grid_el:room_length-grid_el/2, (grid_el/2:grid_el:room_height-grid_el/2)-1.2);

x_flat = x(:);
y_flat = y(:);
z_flat = z(:);

rssi_min_coords = [];
tdoa_min_coords = [];


for file_idx= 1:length(all_mat_files)
    mat_file_path = fullfile(mat_file_dir, all_mat_files(file_idx).name);

    data = load(mat_file_path);
    loss_func_values = data.loss_func_values;  

    errors_flat = loss_func_values(:);
    
    % Find the minimum of the loss function and its coordinates
    [min_val, min_idx] = min(errors_flat);
    min_x = x_flat(min_idx);
    min_y = y_flat(min_idx);
    min_z = z_flat(min_idx);
    
    % Print the coordinates of the minimum of the loss function
    % fprintf('File: %s, Min Value: %f, Coordinates: (%.2f, %.2f, %.2f)\n', all_mat_files(file_idx).name, min_val, min_x, min_y, min_z);
    
    if contains(all_mat_files(file_idx).name, 'rssi')
        rssi_min_coords = [rssi_min_coords; min_x, min_y, min_z];
    elseif contains(all_mat_files(file_idx).name, 'tdoa') 
        tdoa_min_coords = [tdoa_min_coords; min_x, min_y, min_z];
    end

    % Create a 3D scatter plot
    figure();
    scatter3(x_flat, y_flat, z_flat, 36, errors_flat, 'filled');
    colorbar;
    xlabel('X (meters)');
    ylabel('Y (meters)');
    zlabel('Z (meters)');
    if contains(all_mat_files(file_idx).name, 'rssi')
        title('Plot of Loss Function Values for RSSI measurements');
    elseif contains(all_mat_files(file_idx).name, 'tdoa')     
        title('Plot of Loss Function Values for TDOA measurements');
    else 
        title('Unknown measurements, the file name should contain rssi or tdoa.');       
    end
    colormap(jet); 
    set(gca, 'YDir', 'reverse');
    set(gca, 'ZDir', 'reverse');
    % Set color axis limits based on file type
    if contains(all_mat_files(file_idx).name, 'rssi')
        clim([2 70]);
    elseif contains(all_mat_files(file_idx).name, 'tdoa') 
        clim([0.00 0.020]);
    end
end

% Calculate and print the average coordinates for RSSI and TDOA files
if ~isempty(rssi_min_coords)
    avg_rssi_coords = mean(rssi_min_coords, 1);
    fprintf('Average RSSI Coordinates: (%.2f, %.2f, %.2f)\n', avg_rssi_coords(1), avg_rssi_coords(2), avg_rssi_coords(3));
end

if ~isempty(tdoa_min_coords)
    avg_tdoa_coords = mean(tdoa_min_coords, 1);
    fprintf('Average TDOA Coordinates: (%.2f, %.2f, %.2f)\n', avg_tdoa_coords(1), avg_tdoa_coords(2), avg_tdoa_coords(3));
end

%% plot the cross-section of the fine grid

% initialize the room as a grid
room_width = 6;
room_length = 7;
room_height = 4;
grid_el = 0.25;

% List all .mat files in the directory
mat_file_dir = 'loss_func_output/20240805145919';
all_mat_files = dir(fullfile(mat_file_dir, '*.mat'));

[x, y, z] = ndgrid(grid_el/2:grid_el:room_width-grid_el/2, grid_el/2:grid_el:room_length-grid_el/2, (grid_el/2:grid_el:room_height-grid_el/2)-1.2);

% Define the Y coordinate range
y_min = 0;
y_max = 3;

% Flatten the grid data for easy filtering
x_flat = x(:);
y_flat = y(:);
z_flat = z(:);

for file_idx = 1:length(all_mat_files)
    mat_file_path = fullfile(mat_file_dir, all_mat_files(file_idx).name);

    data = load(mat_file_path);
    loss_func_values = data.loss_func_values;  

    % Flatten the loss function values
    loss_func_flat = loss_func_values(:);

    % Filter the data to include only the points within the Y range [y_min, y_max]
    valid_indices = (y_flat >= y_min) & (y_flat <= y_max);

    x_filtered = x_flat(valid_indices);
    y_filtered = y_flat(valid_indices);
    z_filtered = z_flat(valid_indices);
    loss_func_filtered = loss_func_flat(valid_indices);

    % Create a 3D scatter plot for the filtered data
    figure();
    scatter3(x_filtered, y_filtered, z_filtered, 36, loss_func_filtered, 'filled');
    colorbar;
    xlabel('X (meters)');
    ylabel('Y (meters)');
    zlabel('Z (meters)');
    title(sprintf('Plot of Loss Function Values for Y in [%.2f, %.2f]', y_min, y_max));

    % Set colormap and limits based on file type
    colormap(jet);
    if contains(all_mat_files(file_idx).name, 'rssi')
        caxis([2 70]);
        title('Plot of Loss Function Values for RSSI measurements');
    elseif contains(all_mat_files(file_idx).name, 'tdoa')
        caxis([0.00 0.020]);
        title('Plot of Loss Function Values for TDOA measurements');
    else
        title('Unknown measurements, the file name should contain rssi or tdoa.');
    end

    ylim([y_min y_max]);
    set(gca, 'YDir', 'reverse');
    set(gca, 'ZDir', 'reverse'); 

end
