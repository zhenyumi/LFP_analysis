%% Load .mat
clc;close all;clear all;
addpath(genpath('LFP/Scripts'));
addpath('LFP/16p 11.2 group');
% load('LFP/Data/test-data_LFP.mat', 'data', 'fs');
% load("LFP/Data/test-data_LFP_filtered.mat",'data','fs');
load("LFP/Data/test_data_seg.mat");

params.tapers=[3 5];
params.Fs=1000;
params.fpass = [0.1 100];
params.err = 0; % No err calculation
params.trialave=1; % Average over trials
movingwin = [0.5 0.02]; % movingwin = [winsize winstep]

[S,t,f] = mtspecgramc(seg_data_both{1}, movingwin, params);

plot_matrix(S,t,f);
% saveas(gcf,'test.png')
%%
clc;close all;clear all;
addpath(genpath('LFP/Scripts'));
addpath('LFP/16p 11.2 group');

data_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/seg_data_both/';
result_path = 'LFP/Data/results/NOR/heatmaps/';

params.tapers=[3 5];
params.Fs=1000;
params.fpass = [30 100]; % [low_limit upper_limit]
params.err = 0; % No err calculation
params.trialave=1; % Average over trials
movingwin = [0.5 0.02]; % movingwin = [winsize winstep]

channel_names = ["FP04" "FP05" "FP12" "FP13"];

time_type = 'new'; % new or old
data_path = strcat(data_path, time_type, '/');

%6m without LED
file_names = ["3716-11-26-1","3709-11-12-1","1534-4-21-1","1533-4-21-1","1532-4-21-1"];
save_path = strcat(result_path, time_type, '/6m_without_LED/');
%6m with LED
%file_names = ["309-5-28-1","314-5-28-1","1882-5-28-1","1897-5-28-1","3715-11-12-1","3717-11-26-1"];
%save_path = strcat(result_path, time_type, '/6m_with_LED/');
%15m without LED
%file_names = ["MV791-4-21-1","MV794-4-21-1","MV797-4-21-1","3731-11-12-1","3892-11-26-1"];
%save_path = strcat(result_path, time_type, '/15m_without_LED/');
%15m with LED
%file_names = ["318-5-28-2","316-5-28-1","308-5-28-1","319-5-28-1","3732-11-12-1","3891-11-26-1"];
%save_path = strcat(result_path, time_type, '/15m_with_LED/');



for file_name = file_names
    for channel_name = channel_names
        filename = strcat(file_name, "_", channel_name, "_seg.mat");
        NOR_plot_heatmap(data_path, filename, params.tapers, ...
        params.Fs, params.fpass, params.err, params.trialave, movingwin, save_path);
    end
end

