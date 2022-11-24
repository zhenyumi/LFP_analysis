%% Perform preprocessing for coherence analysis

clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';

% If has filtered LFP data (save as xxx.mat), set this variable to true
read_preprocessed_LFP = true;
% If has saved spike data (save as xxx_spike.mat), set this variable to true
read_preprocessed_spike = false;

channel_names = ["FP04" "FP05" "FP12" "FP13"];
% channel_names = ["FP12"];

% 6m
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';
% 6m LED
data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month with 40Hz LED training/';
% 15m
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% 15m LED
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';

file_target = "1882-5-26-1";

for channel_name = channel_names
    file_name = strcat(file_target,"_",channel_name);
    % Read LFP data
    disp("read LFP file");
    if read_preprocessed_LFP
        load_file_path = strcat(save_path,file_name,'.mat');
        load(load_file_path, 'data', 'fs');
        clear load_file_path
        LFP_data = data;
        LFP_Fs = fs;
        clear data fs;
    else
        file = readNex5File(strcat(data_path, file_target, '.nex5'));
        list = file.contvars;
        StringList = [""];
        for i = 1:length(list)
            StringList = [StringList;list{i,1}.name];
        end
        StringList = StringList(2:end);
        channel = listdlg('ListString',StringList);
        fs = list{channel,1}.ADFrequency;
        FP = list{channel,1}.data;
        LFP_data = FP;
        LFP_Fs = fs;
        clear FP fs;
    end
    
    % Read spike data
    disp("read spike file")
    if read_preprocessed_spike
        load_file_path = strcat(save_path,file_name,'_spike.mat');
        load(load_file_path, 'data', 'fs');
        clear load_file_path
        spike_data = data;
        spike_Fs = fs;
        clear data fs;
    else
        file = readNex5File(strcat(data_path, file_target, '.nex5'));
        list = file.contvars;
        StringList = [""];
        for i = 1:length(list)
            StringList = [StringList;list{i,1}.name];
        end
        StringList = StringList(2:end);
        channel = listdlg('ListString',StringList);
        fs = list{channel,1}.ADFrequency;
        FP = list{channel,1}.data;
        spike_data = FP;
        spike_Fs = fs;
        clear FP fs;
    end
    
    % Up-sample LFP data
    disp(strcat("Up-sampling ",file_name," LFP data..."))
    LFP_original = LFP_data;
    LFP_data = interp(LFP_data,spike_Fs/LFP_Fs);
    
    % Save up-sampled LFP data and spike data to .mat file
    save_file_path = strcat(save_path, file_name,"_Coherence.mat");
    save(save_file_path, 'LFP_original', 'LFP_data', 'LFP_Fs','spike_data','spike_Fs');
    clear save_file_path LFP_Fs LFP_data LFP_original spike_Fs spike_data
    
    disp("Done");
end

%% Perform Coherence Analysis
clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));

save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
time_path = "/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/1s_time_intervals/";
result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/coherence/';

params.Fs=40000;
params.fpass=[0 100];
params.tapers=[10 19];
params.trialave=0;
params.err=[1 0.05];

use_readtable = false;
find_approximate_index = true;

channel_names = ["FP04" "FP05" "FP12" "FP13"];
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];

% 6m
subject_names = ["1532-4-18-1","1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
result_path = strcat(result_path, '/6m_without_LED/');

% 15m
%subject_names = ["3731-11-10-1","3892-11-24-1","MV791-4-18-1","MV794-4-18-1","MV797-4-18-1"];
%result_path = strcat(result_path, '/15m_without_LED/');

% 6m LED
%subject_names = ["309-5-26-1","314-5-26-1","1882-5-26-1","1897-5-26-1","3715-11-10-1", "3717-11-24-1"];
%result_path = strcat(result_path, '/6m_with_LED/');

% 15m LED
%subject_names = ["308-5-26-1","316-5-26-1","318-5-26-1","319-5-26-1","3732-11-10-1", "3891-11-24-1"];
%result_path = strcat(result_path, '/15m_with_LED/');

if ~exist(result_path, 'dir')
    mkdir(result_path);
end

LFP_all = {};
sp_all = {};
% Loop begin
for subject_name = subject_names
    for channel_name = channel_names
        file_name = strcat(subject_name, '_',channel_name);
        disp(strcat('Processing: ',file_name));
        % load data
        load_file_path = strcat(save_path,file_name,'_Coherence.mat');
        load(load_file_path, 'LFP_data', 'LFP_Fs','spike_data','spike_Fs');
        clear load_file_path
        % Perform segmentation
        if use_readtable
            times = readtable(strcat(time_path,subject_name, '.xlsx'));
        else
            times = xlsread(strcat(time_path,subject_name, '.xlsx'));
            times = array2table(times);
        end
        start_times = table2array(times(:,1));
        end_times = table2array(times(:,2));
        clear times;

        datalfp = {};
        datasp = {};
        fs = spike_Fs;
        for i = 1:length(start_times)
             start = start_times(i);
             ends = end_times(i);
             datalfp{i} = LFP_data(start*fs+1:ends*fs);
             LFP_all{end+1} = LFP_data(start*fs+1:ends*fs);
             datasp{i} = spike_data(start*fs+1:ends*fs);
             sp_all{end+1} = spike_data(start*fs+1:ends*fs);
        end

        % datalfp = cell2mat(datalfp);
        % datasp = cell2mat(datasp);

        % Calculate LFP-Spike Coherence
        % [C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencycpt(datalfp,datasp,params);
        
    end
end

mean_coherence = {};
all_coherence = {};
all_frequency = {};

data_size = size(LFP_all);
h=waitbar(0,'Calculating coherence');
for i = 1:data_size(2)
    datalfp = LFP_all{i};
    datasp = sp_all{i};
    [C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencycpt(datalfp,datasp,params);
    all_coherence{end+1} = C;
    all_frequency{end+1} = f;
    for j = 1:length(fre_bands(:,1))
          freq_band = [fre_bands(j,1) fre_bands(j,2)];
          [tmp_coherence,tmp_freq] = cut_by_freq(C,f,freq_band,find_approximate_index);
          mean_coherence{i,j} = mean(tmp_coherence);
    end
    waitbar(i/data_size(2),h);
end
delete(h);
clear i j;
% Construct data table to save
table_mean_coherence = cell2table(mean_coherence);
table_all_coherence = {};
table_all_frequency = {};
for i = 1:length(all_coherence)
    for j = 1:length(all_coherence{i})
        table_all_coherence{i, j} = all_coherence{i}(j);
    end
end
table_all_coherence = cell2table(table_all_coherence);
for i = 1:length(all_frequency)
    for j = 1:length(all_frequency{i})
        table_all_frequency{i, j} = all_frequency{i}(j);
    end
end
table_all_frequency = cell2table(table_all_frequency);
% clear mean_coherence all_coherence all_frequency
% Set table column names
table_colnames = [];
size_frebands = size(fre_bands);
for i = 1:size_frebands(1)
    title = sprintf("%1$0.1f to %2$0.1f",fre_bands(i,1),fre_bands(i,2));
    table_colnames = [table_colnames;title];
end
table_mean_coherence.Properties.VariableNames = table_colnames;
clear i title table_colnames
% Save as .xlsx
name_xlsx = strcat(result_path, 'coherence_result.xlsx');
writetable(table_mean_coherence, name_xlsx, "Sheet", 'Mean Coherence');
writetable(table_all_coherence, name_xlsx, "Sheet", 'Raw Coherence');
writetable(table_all_frequency, name_xlsx, "Sheet", 'Related frequency');
disp("Data Saved");
%%
Test Data Below
%%
datalfp = cell2mat(LFP_all);
datasp = cell2mat(sp_all);
[C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencycpt(datalfp,datasp,params);
% avg_C = mean(C,2);
% plot(f,avg_C);
%%
find_approximate_index = true;

mean_coherence = [];
title_mean_cohr = [];
original_coherence = {};
original_freqs = {};

fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
size_frebands = size(fre_bands);
title_freqs = [];
for i = 1:size_frebands(1)
    [data_c,freq_c] = cut_by_freq(avg_C,f,fre_bands(i,:),find_approximate_index);
    original_coherence{end+1} = data_c;
    original_freqs{end+1} = freq_c;
    title = sprintf("%1$0.1f to %2$0.1f",fre_bands(i,1),fre_bands(i,2));
    title_freqs = [title_freqs;title];
    title_mean_cohr = [title_mean_cohr;title];
    mean_coherence = [mean_coherence;mean(data_c)];
end

table_mean_coherence = table(title_mean_cohr);
table_mean_coherence(:,2) = table(mean_coherence);
%table_original_freqs = cell2table(original_freqs);

table_original_coherence = {};
for i = 1:length(original_coherence)
    for j = 1:length(original_coherence{i})
        table_original_coherence{i, j} = original_coherence{i}(j);
    end
end
clear i j original_coherence
table_original_coherence = cell2table(table_original_coherence');
table_original_coherence.Properties.VariableNames = title_freqs;

table_original_freqs = {};
for i = 1:length(original_freqs)
    for j = 1:length(original_freqs{i})
        table_original_freqs{i, j} = original_freqs{i}(j);
    end
end
clear i j original_freqs
table_original_freqs = cell2table(table_original_freqs');
table_original_freqs.Properties.VariableNames = title_freqs;

clear original_freqs title title_mean_cohr mean_coherence

