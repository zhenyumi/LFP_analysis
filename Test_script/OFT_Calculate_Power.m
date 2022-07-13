%% Set environment
clc;close all;clear;

% Please set the path correctly !!!
% Please set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of .nex5 file)
% data_path = 'LFP/Data/nex5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';
data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month with 40Hz LED training/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';
addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/1s_time_intervals/';
%Set path of saved processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
%Set path to save the result calculated
result_path = 'LFP/Data/results/trapz_1s/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = '3717-11-24-2';
% channel_name = 'FP13';
channel_names = ["FP04" "FP05" "FP12" "FP13"];
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
for channel_name = channel_names
    disp(channel_name);
    CalculateAllPower(data_path,time_path,save_path,result_path,file_name,channel_name,true,true,fre_bands,true);
    disp(strcat('Done: ', file_name, '--', channel_name))
end
%% Set environment _ test
clc;close all;clear;

% Please set the path correctly !!!
% Please set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of .nex5 file)
% data_path = 'LFP/Data/nex5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';
data_path = '/Volumes/Seagate Basic/16p 11.2 group/40Hz LED training for 0 days/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';
addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = '/Volumes/Seagate Basic/16p 11.2 group/40Hz LED training for 0 days/';
%Set path of saved processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/16p 11.2 group/40Hz LED training for 0 days/';
%Set path to save the result calculated
result_path = '/Volumes/Seagate Basic/16p 11.2 group/40Hz LED training for 0 days/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = '0717-233-1';
% channel_name = 'FP13';
% channel_names = ["FP04" "FP05" "FP12" "FP13"];
channel_names = ["FP04"];
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
for channel_name = channel_names
    disp(channel_name);
    CalculateAllPower(data_path,time_path,save_path,result_path,file_name,channel_name,true,true,fre_bands,true);
    disp(strcat('Done: ', file_name, '--', channel_name))
end