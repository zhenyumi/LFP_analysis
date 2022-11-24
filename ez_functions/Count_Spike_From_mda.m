clear;clc;
% Setup
% Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
% Set variables
Sampling_frequency = 40000;
time_interval_length = 1;
use_readtable = true;

data_path = "/Volumes/Seagate Basic/LFP/Spike/firing_data/";
result_path = "/Volumes/Seagate Basic/LFP/Spike/results/";
time_path = 'LFP/Data/time_intervals/1s_time_intervals/';

% 6 months
subject_names = ["1532-4-18-1","1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
% 15 months
% subject_names = ["3731-11-10-1","3892-11-24-1","MV791-4-18-1","MV794-4-18-1","MV797-4-18-1"];
% 6 months LED
% subject_names = ["309-5-26-1","314-5-26-1","1882-5-26-1","1897-5-26-1","3715-11-10-1", "3717-11-24-1"];
% 15 months LED
% subject_names = ["308-5-26-1","316-5-26-1","318-5-26-1","319-5-26-1", "3891-11-24-1"];
for subject_name = subject_names
    subject_id = strsplit(subject_name,"-");
    subject_id = subject_id(1);
    
    % Read .mda file and extract information
    file_path = strcat(data_path, subject_id, "_firing.mda");
    Firing_result = readmda_modified(file_path);
    spike_location = Firing_result(1,:);
    spike_tp = Firing_result(2,:);
    spike_cluster = Firing_result(3,:);
    clear Firing_result file_path
    
    % Data segmentation
    selected_tp = {};
    if use_readtable
        times = readtable(strcat(time_path,subject_name, '.xlsx'));
    else
        times = xlsread(strcat(time_path,subject_name, '.xlsx'));
        times = array2table(times);
    end
    start_times = table2array(times(:,1));
    end_times = table2array(times(:,2));
    clear times;
    
    for k = 1:length(start_times)
        start = start_times(k);
        ends = end_times(k);
        start_tp = start*Sampling_frequency + 1;
        end_tp = ends*Sampling_frequency;
        [~,sp_Index_start] = min(abs(spike_tp-start_tp));
        [~,sp_Index_end] = min(abs(spike_tp-end_tp));
        selected_tp{end+1} = spike_cluster(sp_Index_start:sp_Index_end);
    end
    clear start ends start_tp end_tp sp_Index_end sp_Index_start ~ k start_times end_times
    
    % Count the total spike cluster
    all_clusters = [];
    for k = 1:length(selected_tp)
        all_clusters = [all_clusters,selected_tp{k}]
    end
    
    total_tp = length(all_clusters);
    total_time = length(selected_tp) * time_interval_length;
    Count_result = tabulate(all_clusters);
    result_table = array2table(Count_result,'VariableNames', ...
        {'Cluster No.', 'Count', 'Percent'});
    
    tmp_tableSize = size(result_table(:,1));
    varNames = ["Firing Rate (sp/sec)","Total Time Point","Sampling Frequency"];
    varTypes = ["double","double","double"];
    sz = [tmp_tableSize(1) 3];
    temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    for i = 1:tmp_tableSize(1)
        temps{i,1} = result_table{i,'Count'}/total_time;
    end
    temps{1,2} = total_tp;
    temps{1,3} = Sampling_frequency;
    result_table = [result_table temps];
    clear temps total_tp total_time tmp_tableSize varNames varTypes sz i k;
    
    % Count spike for each time intervals
    Time_count_result = [];
    cluster_No = Count_result(:,1)'; % Here is a transpose
    
    for k = 1:length(selected_tp)
        tmp_count = [];
        for m = 1:length(cluster_No)
            Time_count_result(k,m) = length(find(selected_tp{k}==cluster_No(m)));
        end
    end
    clear k tmp_count m
    
    tmp_col_names = [];
    for k = 1:length(cluster_No)
        tmp_col_names = [tmp_col_names,sprintf("Cluster %d", k)];
    end
    tmp_row_names = [];
    for k = 1:length(selected_tp)
        tmp_row_names = [tmp_row_names, sprintf("Time segment %d", k)];
    end
    tmp_row_names = array2table(tmp_row_names');
    
    table_time_count = array2table(Time_count_result);
    table_time_count.Properties.VariableNames = tmp_col_names;
    table_time_count = [tmp_row_names table_time_count];
    
    clear cluster_No k tmp_row_names tmp_col_names
    
    % Save result to .xlsx file
    name_xlsx = strcat(result_path, subject_id, "_", 'Spike_Firing_result.xlsx');
    writetable(result_table, name_xlsx, "Sheet", 'Summary');
    writetable(table_time_count, name_xlsx, "Sheet", 'Spike Firing Rates');
    disp("Result saved");
end
%% Test code
clear;clc;
% Setup
% Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
% Set variables
Sampling_frequency = 40000;
time_interval_length = 1;
use_readtable = true;

data_path = "/Volumes/Seagate Basic/LFP/Spike/firing_data/";
result_path = "/Volumes/Seagate Basic/LFP/Spike/results/";
time_path = 'LFP/Data/time_intervals/1s_time_intervals/';

% 6 months
subject_names = ["1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
subject_name = "1533-4-18-1";
subject_id = strsplit(subject_name,"-");
subject_id = subject_id(1);

% Read .mda file and extract information
%strsplit(a,"-");
Firing_result = readmda_modified("/Volumes/Seagate Basic/LFP/Spike/firing_data/spkc1533_firing.mda");
spike_location = Firing_result(1,:);
spike_tp = Firing_result(2,:);
spike_cluster = Firing_result(3,:);
clear Firing_result

% Data segmentation
selected_tp = {};
if use_readtable
    times = readtable(strcat(time_path,subject_name, '.xlsx'));
else
    times = xlsread(strcat(time_path,subject_name, '.xlsx'));
    times = array2table(times);
end
start_times = table2array(times(:,1));
end_times = table2array(times(:,2));
clear times;

for k = 1:length(start_times)
    start = start_times(k);
    ends = end_times(k);
    start_tp = start*Sampling_frequency + 1;
    end_tp = ends*Sampling_frequency;
    [~,sp_Index_start] = min(abs(spike_tp-start_tp));
    [~,sp_Index_end] = min(abs(spike_tp-end_tp));
    selected_tp{end+1} = spike_cluster(sp_Index_start:sp_Index_end);
end
clear start ends start_tp end_tp sp_Index_end sp_Index_start ~ k start_times end_times

% Count the total spike cluster
all_clusters = [];
for k = 1:length(selected_tp)
    all_clusters = [all_clusters,selected_tp{k}]
end

total_tp = length(all_clusters);
total_time = length(selected_tp) * time_interval_length;
Count_result = tabulate(all_clusters);
result_table = array2table(Count_result,'VariableNames', ...
    {'Cluster No.', 'Count', 'Percent'});

tmp_tableSize = size(result_table(:,1));
varNames = ["Firing Rate (sp/sec)","Total Time Point","Sampling Frequency"];
varTypes = ["double","double","double"];
sz = [tmp_tableSize(1) 3];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
for i = 1:tmp_tableSize(1)
    temps{i,1} = result_table{i,'Count'}/total_time;
end
temps{1,2} = total_tp;
temps{1,3} = Sampling_frequency;
result_table = [result_table temps];
clear temps total_tp total_time tmp_tableSize varNames varTypes sz i k;

% Count spike for each time intervals
Time_count_result = [];
cluster_No = Count_result(:,1)'; % Here is a transpose

for k = 1:length(selected_tp)
    tmp_count = [];
    for m = 1:length(cluster_No)
        Time_count_result(k,m) = length(find(selected_tp{k}==cluster_No(m)));
    end
end
clear k tmp_count m

tmp_col_names = [];
for k = 1:length(cluster_No)
    tmp_col_names = [tmp_col_names,sprintf("Cluster %d", k)];
end
tmp_row_names = [];
for k = 1:length(selected_tp)
    tmp_row_names = [tmp_row_names, sprintf("Time segment %d", k)];
end
tmp_row_names = array2table(tmp_row_names');

table_time_count = array2table(Time_count_result);
table_time_count.Properties.VariableNames = tmp_col_names;
table_time_count = [tmp_row_names table_time_count];

clear cluster_No k tmp_row_names tmp_col_names

% Save result to .xlsx file
name_xlsx = strcat(result_path, subject_id, "_", 'Spike_Firing_result.xlsx');
writetable(result_table, name_xlsx, "Sheet", 'Summary');
writetable(table_time_count, name_xlsx, "Sheet", 'Spike Firing Rates');
disp("Result saved");
