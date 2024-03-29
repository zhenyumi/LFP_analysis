clear;clc;
% Setup
%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
addpath("/Users/zhangzhenzhen/Documents/MATLAB/fieldtrip");
% set config
cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [1.5:0.5:4];
cfg.amp_freqs           = [6:1:80];
cfg.method              = 'tort'; %('tort','ozkurt','plv','canolty)
cfg.filt_order          = 3;
% cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 5;
cfg.avg_PAC             = 'yes';

% Set NOR related configs
state = 'pre'; % pre (approach) or post (exploring)
behavior_type = 'new'; % old object or new object
time_lag = 1.0; % How long (Unit: second) before or after the selected time point

% use *readtable* function or not
use_readtable = true;

% Smoothen the heatmap or not
smooth = true;
set_colorlimit = false;
%colorlimit = [0 0.028]; %Phase-Theta
colorlimit = [0 7e-3]; %Phase-Alpha

% Set the phase and frequency range that 
phase_range = [2 4];
amplitude_range = [50 80];


file_path = '/Volumes/Seagate Basic/LFP/LFP/NOR_preprocessed_data/';
time_path = "/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/NOR_time_intervals/";
result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/modulation_index/';

channel_names = ["FP04" "FP05" "FP12" "FP13"];

% 6m x Tranining x LED
subject_names = ["1532-4-18-1","1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
result_path = strcat(result_path, '/6m_without_LED/');

save_path = result_path;

if ~exist(save_path, 'dir')
    mkdir(save_path);
end
fig_folder = strcat(save_path, 'heatmaps/');
if ~exist(fig_folder,'dir')
    mkdir(fig_folder);
end

names = {};
MIs = [];
MI_matrixes = {};

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
        if use_readtable
            times = readtable(strcat(time_path,subject_name, '.xlsx'));
        else
            times = xlsread(strcat(time_path,subject_name, '.xlsx'));
            times = array2table(times);
        end
        % Read time that contact object
        % The first column in excel should be time for **New** object, the
        % second column should be time for **Old** object
        % end_times = table2array(times(:,2)) - time_lag;
        % start_times = table2array(times(:,2));
        if strcmp(behavior_type,'new')
            target_times = table2array(times(:,1));
        elseif strcmp(behavior_type, 'old')
            target_times = table2array(times(:,2));
        else
            disp("No time data readed, check the excel format or **behavior_type** config in the script")
        end
        clear times;
        
        % Calculate start time and end time by given state (pre or post)
        target_times = target_times(~isnan(target_times));
        if strcmp(state, 'pre')
            start_times = target_times - time_lag;
            end_times = target_times;
        elseif strcmp(state, 'post')
            start_times = target_times;
            end_times = target_times + time_lag;
        else
            disp('start and end time error, chack the excel format or the **state** config')
        end
        clear target_times

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
        MI_matrixes{end+1} = MI_raw;
        
        set(0,'DefaultFigureVisible', 'off');
        plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);
        %caxis([0 0.15]);
        colorbar;
        colormap turbo; % default(parula); turbo; jet; 
        fig_name = strcat(fig_folder, file_name,'.png');
        saveas(gcf,fig_name);
        close(gcf);
        
        % Calculate mean PAC-MI value of a specific phase and frequency range
        SubMatrix = ExtractSubMatrix(MI_raw,cfg.amp_freqs, cfg.phase_freqs, ...
            amplitude_range, phase_range);
        
        MI_mean = mean(SubMatrix, 'all');
        
        names{end+1} = file_name;
        MIs(end+1) = MI_mean;
    end
end

T = table(names',MIs');
excel_name = strcat(save_path, 'MIs.xlsx');
if use_readtable
    writetable(T,excel_name, 'WriteVariableNames',false);
else
    T = table2cell(T);
    xlswrite(excel_name,T);
end

MI_mat = [];
for i = 1:length(MI_matrixes)
    item = MI_matrixes{i};
    MI_mat(:,:,i) = item;
end

MI_mean_mat = mean(MI_mat,3);
set(0,'DefaultFigureVisible', 'off');
if smooth 
    data = MI_mean_mat;
    %// Define integer grid of coordinates for the above data
    [X,Y] = meshgrid(1:size(data,2), 1:size(data,1));
    %// Define a finer grid of points
    [X2,Y2] = meshgrid(1:0.01:size(data,2), 1:0.01:size(data,1));
    %// Interpolate the data and show the output
    outData = interp2(X, Y, data, X2, Y2, 'linear');
    phase_extend = linspace(min(cfg.phase_freqs),max(cfg.phase_freqs),size(outData,1));
    amplitude_extend = linspace(min(cfg.amp_freqs),max(cfg.amp_freqs),size(outData,2));
    plot_comod_m(phase_extend,amplitude_extend,outData);
else
    plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_mean_mat);
end
colorbar;
colormap turbo;
xlabel("");
ylabel("");
title("");
if set_colorlimit
    caxis(colorlimit);
end
fig_name = strcat(save_path, 'averaged','.png');
saveas(gcf,fig_name);
%% smooth
smooth = true;
if smooth 
    data = MI_mean_mat;
    %// Define integer grid of coordinates for the above data
    [X,Y] = meshgrid(1:size(data,2), 1:size(data,1));
    %// Define a finer grid of points
    [X2,Y2] = meshgrid(1:0.01:size(data,2), 1:0.01:size(data,1));
    %// Interpolate the data and show the output
    outData = interp2(X, Y, data, X2, Y2, 'linear');
    phase_extend = linspace(min(cfg.phase_freqs),max(cfg.phase_freqs),size(outData,1));
    amplitude_extend = linspace(min(cfg.phase_freqs),max(cfg.amp_freqs),size(outData,2));
    plot_comod(phase_extend,amplitude_extend,MI_mean_mat);
else
    plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_mean_mat);
end
colorbar;
colormap turbo;
fig_name = strcat(save_path, 'averaged','.png');
saveas(gcf,fig_name);
%%
MI_mat = [];
for i = 1:length(MI_matrixes)
    item = MI_matrixes{i};
    MI_mat(:,:,i) = item;
end

MI_mean_mat = mean(MI_mat,3);

set(0,'DefaultFigureVisible', 'on');
plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);