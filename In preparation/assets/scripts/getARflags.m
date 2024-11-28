

%% Export event and urevent

%% File navigation

% Output directory
output_dir = 'Testing_Triallevel\ARflagList\';

% Get all file names ending with .set in the current folder
files = dir('16a_800ERPs\*.erp');

%% Loop through each file
for i = 1:length(files)
    filename = files(i).name;
    subid = filename(1:5);
    path = strcat('16a_800ERPs\', filename);
    outputpath = char([output_dir 'ARflagList_' subid '.txt']);

    ERP = pop_loaderp('filepath', path);
    
    % Extract the eventinfo structure
    eventinfo = struct2table(ERP.EVENTLIST.eventinfo);

    % Filter rows where the code ends with 1 or 2
    filtered_table = eventinfo(endsWith(string(eventinfo.code), {'1', '2'}), :);

    % Convert the filtered table back to a structure array if needed
    filtered_eventinfo = table2struct(filtered_table);

    % Write the filtered table to a CSV file
    writetable(filtered_table, outputpath);

end


