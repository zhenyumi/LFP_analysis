clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
% set config
cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [4:0.5:10];
% cfg.phase_freqs         = [2:1:24];
cfg.amp_freqs           = [25:1:100];
cfg.method              = 'tort'; %('tort','ozkurt','plv','canolty)
% cfg.filt_order          = 3;
cfg.filt_order          = 3;
% cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 15;
cfg.avg_PAC             = 'yes';

phase_range = [4 8];
amplitude_range = [30 50];

file_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/preprocessed_data/';

time_path = "/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/1s_time_intervals/";

result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/modulation_index/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end
fig_folder = strcat(result_path, 'heatmaps/');
if ~exist(fig_folder,'dir')
    mkdir(fig_folder);
end

subject_name = '316-5-26-1';
channel_name = "FP04";
names = {};
MIs = [];

%loop begin

file_name = strcat(subject_name, '_',channel_name);
disp(strcat('Processing: ',file_name));
% Perform PAC

load_file_path = strcat(file_path,file_name,'.mat');
load(load_file_path, 'data', 'fs');
clear load_file_path

% Perform segmentation
times = readtable(strcat(time_path,subject_name, '.xlsx'));
        start_times = table2array(times(:,1));
        end_times = table2array(times(:,2));
        clear times;
        
        seg_data = {};
       
        
        for i = 1:length(start_times)
            start = start_times(i);
            ends = end_times(i);
            seg_data{i} = data(start*fs+1:ends*fs);
        end
        
        clear data start ends i start_times end_times;

%signal = data(16000:19000)';
signal = cell2mat(seg_data)'; % ! Here is a transpose
% signal = seg_data{6}';
% [MI_raw,MI_surr] = PACmeg(cfg,signal);

[MI_raw] = PACmeg(cfg,signal);

plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);
%caxis([0 0.15]);
colorbar;
colormap parula; % default(parula); turbo; jet; 
fig_name = strcat(fig_folder, file_name,'.png');
saveas(gcf,fig_name);

SubMatrix = ExtractSubMatrix(MI_raw,cfg.amp_freqs, cfg.phase_freqs, ...
    amplitude_range, phase_range);

MI_mean = mean(SubMatrix, 'all');

names{end+1} = file_name;
MIs(end+1) = MI_mean;


%% Loop
clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
% set config
cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [4:0.5:10];
% cfg.phase_freqs         = [2:1:24];
cfg.amp_freqs           = [25:1:100];
cfg.method              = 'tort'; %('tort','ozkurt','plv','canolty)
% cfg.filt_order          = 3;
cfg.filt_order          = 3;
% cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 15;
cfg.avg_PAC             = 'yes';

phase_range = [4 8];
amplitude_range = [30 50];

file_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/preprocessed_data/';
time_path = "/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/1s_time_intervals/";
result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/modulation_index/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end
fig_folder = strcat(result_path, 'heatmaps/');
if ~exist(fig_folder,'dir')
    mkdir(fig_folder);
end

channel_names = ["FP04" "FP05" "FP12" "FP13"];
subject_names = ["316-5-26-1","316-5-26-2"];

names = {};
MIs = [];

%loop begin
for subject_name = subject_names
    for channel_name = channel_names
        file_name = strcat(subject_name, '_',channel_name);
        disp(strcat('Processing: ',file_name));
        % Perform PAC
        
        load_file_path = strcat(file_path,file_name,'.mat');
        load(load_file_path, 'data', 'fs');
        clear load_file_path
        
        % Perform segmentation
        times = readtable(strcat(time_path,subject_name, '.xlsx'));
                start_times = table2array(times(:,1));
                end_times = table2array(times(:,2));
                clear times;
                
                seg_data = {};
               
                
                for i = 1:length(start_times)
                    start = start_times(i);
                    ends = end_times(i);
                    seg_data{i} = data(start*fs+1:ends*fs);
                end
                
                clear data start ends i start_times end_times;
        
        %signal = data(16000:19000)';
        signal = cell2mat(seg_data)'; % ! Here is a transpose
        % signal = seg_data{6}';
        % [MI_raw,MI_surr] = PACmeg(cfg,signal);
        
        [MI_raw] = PACmeg(cfg,signal);
        
        plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);
        %caxis([0 0.15]);
        colorbar;
        colormap parula; % default(parula); turbo; jet; 
        fig_name = strcat(fig_folder, file_name,'.png');
        saveas(gcf,fig_name);
        close(gcf);
        
        SubMatrix = ExtractSubMatrix(MI_raw,cfg.amp_freqs, cfg.phase_freqs, ...
            amplitude_range, phase_range);
        
        MI_mean = mean(SubMatrix, 'all');
        
        names{end+1} = file_name;
        MIs(end+1) = MI_mean;
    end
end

T = table(names',MIs');
excel_name = strcat(result_path, 'MIs.xlsx');
writetable(T,excel_name, 'WriteVariableNames',false);
%% test
%SubMatrix = ExtractSubMatrix(MI_raw,cfg.amp_freqs, cfg.phase_freqs, [25 26], [4 8]);
if ~exist(result_path, 'dir')
    mkdir(result_path);
end

MI_folder = strcat(result_path, 'MI/');

if ~exist(MI_folder,'dir')
    mkdir(MI_folder);
end

%%
clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
a = readmda_modified("/Volumes/Seagate Basic/DATA/6M/spkc1533_new.mda");