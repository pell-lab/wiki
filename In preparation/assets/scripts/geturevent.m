

%% Export event and urevent

%% File navigation

% Output directory
output_dir = 'Testing_Triallevel\';

% Get all file names ending with .set in the current folder
files = dir('11_TP9TP10\*.set');

%% Loop through each file
for i = 1:length(files)
    filename = files(i).name;
    subid = filename(1:5);
    path = strcat('11_TP9TP10\', filename);

    EEG = pop_loadset(path);

    event_table = struct2table(EEG.event);

    event_table = event_table(:, {'type', 'urevent'});

    urevent_table = struct2table(EEG.urevent);

    urevent_table = urevent_table(:, {'type', 'bvmknum'});

    writetable(event_table, [output_dir subid '_EEG_event_data.csv']);

    writetable(urevent_table, [output_dir subid '_EEG_urevent_data.csv']);
end


