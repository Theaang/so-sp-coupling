% First dimension, keeping only the first row
first_dimension = squeeze(all_dc.sosp_num_dc(1, :, :, :, :));

% Naming the fourth dimension
fourth_dimension_labels = {'stage name','F3', 'F4', 'C3', 'C4', 'O1', 'O2', 'P3', 'P4', 'Fp1', 'Fp2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'FT9', 'FT10', 'Fz', 'Cz', 'CPz', 'Pz', 'POz', 'Fpz'};

% Initialize an empty cell array to store the data
data = cell(56, 26); % Increase the size of the cell array to accommodate stage labels and row names

% Loop through participants
for participant = 1:size(all_dc.sosp_num_dc, 5)
    for stage = 1:2 % nREM2 and SWS
        % Sum the third dimension for each 1:4 range
        third_dimension_sum = sum(all_dc.sosp_num_dc(1, :, 1:4, :, participant), 3, 'omitnan');
        
        % Determine the label for the stage based on the current iteration
        if stage == 1
            stage_label = 'nREM2';
        else
            stage_label = 'SWS';
        end
        
        % Create a unique row name for this row
        row_name = ['Participant' num2str(participant) '_' stage_label];
       
        % Store the data in the cell array
        % Use {} to create a cell array for stage_label
        data{(participant - 1) * 2 + stage, 1} = stage_label;
        
        % Loop through the elements of third_dimension_sum and assign them individually
        for electrode = 1:numel(third_dimension_sum)
            data{(participant - 1) * 2 + stage, electrode + 1} = third_dimension_sum(electrode);
        end
    end
end

% Determine the number of rows in data
num_rows = size(data, 1);

% Determine the columns to keep based on row parity
odd_columns_to_keep = [1, 2:2:49]; % For odd rows
even_columns_to_keep = [1, 3:2:49]; % For even rows

% Initialize a cell array to store the filtered data
filtered_data = cell(num_rows, length(odd_columns_to_keep));

% Loop through rows
for i = 1:num_rows
    % Determine which columns to keep based on row parity
    if mod(i, 2) == 1 % Odd row
        columns_to_keep = odd_columns_to_keep;
    else % Even row
        columns_to_keep = even_columns_to_keep;
    end
    
    % Copy the selected columns from the original data to filtered_data
    for j = 1:length(columns_to_keep)
        filtered_data{i, j} = data{i, columns_to_keep(j)};
    end
end

disp(filtered_data)
% Manually specify row names for all 56 rows
row_names = cell(num_rows, 1);
for i = 1:num_rows
    if mod(i, 2) == 0
        stage_name = 'SWS';
    else
        stage_name = 'nREM2';
    end
    row_names{i} = ['Participant' num2str(ceil(i / 2)) '_' stage_name];
end

% Create a new binary column representing nREM2 or SWS
second_dimension_labels = repmat({'nREM2'; 'SWS'}, size(all_dc.sp_numbers_dc, 5), 1);

% Combine the filtered data with the new binary column
T_filtered = cell2table(filtered_data, 'VariableNames', fourth_dimension_labels, 'RowNames', row_names);

% Save the table as a CSV file
writetable(T_filtered, 'coupled_sp_number.csv');