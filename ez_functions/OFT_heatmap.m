%% Draw a Smoothed heatmap
clc;close all;clear;
addpath(genpath('LFP/Scripts'));

file_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
time_path = "/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/1s_time_intervals/";
result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/OFT_heatmap/';

channel_names = ["FP04" "FP05" "FP12" "FP13"];

params.tapers=[4 7];
params.Fs=1000;
params.fpass = [30 90];
params.err = 0; % No err calculation
params.trialave=1; % Average over trials
movingwin = [0.5 0.02]; % movingwin = [winsize winstep] [0.5 0.02]
log = 'l'; % 'n' for not 10log10, 'l' for 10 log10
% Smooth the heatmap or not
smooth = true;
%[-42 -30] for 1-8 Hz; [-50 -35] for 8-30 Hz; [-57 -45] for 30-90 Hz
colormap_limit = [-57 -45]; 
%6m x Tranining x LED
%subject_names = ["1532-4-18-1","1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
%save_path = strcat(result_path, '/6m_without_LED/');

%6m with LED
%subject_names = ["309-5-26-1","314-5-26-1","1882-5-26-1","1897-5-26-1","3715-11-10-1", "3717-11-24-1"];
%save_path = strcat(result_path, '/6m_with_LED/');

%15m x Tranining x LED
subject_names = ["3731-11-10-1","3892-11-24-1","MV791-4-18-1","MV794-4-18-1","MV797-4-18-1"];
save_path = strcat(result_path, '/15m_without_LED/');

%15m with LED
%subject_names = ["318-5-28-2","316-5-28-1","308-5-28-1","319-5-28-1","3732-11-12-1","3891-11-26-1"];
%save_path = strcat(result_path, '/15m_with_LED/');

if ~exist(save_path, 'dir')
    mkdir(save_path);
end
all_data = {};
for subject_name = subject_names
    for channel_name = channel_names
        file_name = strcat(subject_name, '_',channel_name);
        disp(strcat('Processing: ',file_name));
        load_file_path = strcat(file_path,file_name,'.mat');
        load(load_file_path, 'data','fs');
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

        signal = cell2mat(seg_data);
        figure_name = strcat(subject_name, '_', channel_name);
        plot_heatmap(signal(:,2),figure_name, true,params.tapers,params.Fs,params.fpass,...
            params.err,params.trialave, movingwin, save_path, log);
        for k = 1:length(seg_data)
            all_data{end+1} = seg_data{k};
        end
    end
end
signal = cell2mat(all_data);
[S,t,f] = mtspecgramc(signal, movingwin, params);
if smooth
    data = S;
    %// Define integer grid of coordinates for the above data
    [X,Y] = meshgrid(1:size(data,2), 1:size(data,1));
    %// Define a finer grid of points
    [X2,Y2] = meshgrid(1:0.01:size(data,2), 1:0.01:size(data,1));
    %// Interpolate the data and show the output
    outData = interp2(X, Y, data, X2, Y2, 'linear');
    f_extend = linspace(min(params.fpass),max(params.fpass),size(outData,2));
    t_extend = linspace(0,1,size(outData,1));
    
    plot_matrix(outData,t_extend,f_extend);
else
    plot_matrix(S,t,f,log);
end
fig_name = strcat(result_path,'_average', '.png');
colormap turbo
caxis(colormap_limit); 
xlabel("");
ylabel("");
title("");
saveas(gcf,fig_name);