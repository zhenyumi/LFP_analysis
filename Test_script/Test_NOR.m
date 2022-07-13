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
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month with 40Hz LED training/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';
%%%%% NOR
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/6 month without LED training/6 month without LED training_NEX5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/6 month with 40Hz LED training/6 month with 40 Hz LED training_NEX5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/15 month without LED training/15 month without light training_NEX5/';
data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/15 month with 40 Hz LED training/15 month with 40Hz LED training_NEX5/';

addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/NOR_time_intervals/';
%Set path of saved processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
%Set path to save the result calculated
result_path = 'LFP/Data/results/NOR/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = '3891-11-26-1';
% channel_name = 'FP13';
channel_names = ["FP04" "FP05" "FP12" "FP13"];
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
for channel_name = channel_names
    disp(channel_name);

    params.data_dir = data_path;
    params.time_dir = time_path;
    params.save_dir = save_path;
    params.result_dir = result_path;
    params.sample_name = file_name;
    params.channel_info = channel_name;

    params.preprocessing = false;
    params.analyze = true;

    params.freq_band_to_analyze = fre_bands;

    params.detrend = false;

    % NOR_CalculateAllPower(data_path,time_path,save_path,result_path,file_name,channel_name,true,true,fre_bands, true);

    NOR_CalculateAllPower(params.data_dir,params.time_dir,params.save_dir, ...
        params.result_dir,params.sample_name,params.channel_info, ...
        params.preprocessing,params.analyze,params.freq_band_to_analyze,...
        params.detrend);
        
    % NOR_CalculateAllPower(data_path, params);
    disp(strcat('Done: ', file_name, '--', channel_name))
end
%% with loop

clc;close all;clear;

% Please set the path correctly !!!
% Please set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of .nex5 file)
% data_path = 'LFP/Data/nex5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month with 40Hz LED training/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';
%%%%% NOR
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/6 month without LED training/6 month without LED training_NEX5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/6 month with 40Hz LED training/6 month with 40 Hz LED training_NEX5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/15 month without LED training/15 month without light training_NEX5/';
data_path = '/Volumes/Seagate Basic/LFP/code20210409/新型物体识别/15 month with 40 Hz LED training/15 month with 40Hz LED training_NEX5/';

addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/NOR_time_intervals/';
%Set path of saved processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
%Set path to save the result calculated
result_path = 'LFP/Data/results/NOR/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)

%6m without LED
file_names = ["3716-11-26-1","3709-11-12-1","1534-4-21-1","1533-4-21-1","1532-4-21-1"];
%6m with LED
%file_names = ["309-5-28-1","314-5-28-1","1882-5-28-1","1897-5-28-1","3715-11-12-1","3717-11-26-1"];
%15m without LED
%file_names = ["MV791-4-21-1","MV794-4-21-1","MV797-4-21-1","3731-11-12-1","3892-11-26-1"];
%15m with LED
%file_names = ["318-5-28-2","316-5-28-1","308-5-28-1","319-5-28-1","3732-11-12-1","3891-11-26-1"];

% channel_name = 'FP13';
channel_names = ["FP04" "FP05" "FP12" "FP13"];
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
for file_name = file_names
    disp(file_name);
    for channel_name = channel_names
        disp(channel_name);
    
        params.data_dir = data_path;
        params.time_dir = time_path;
        params.save_dir = save_path;
        params.result_dir = result_path;
        params.sample_name = file_name;
        params.channel_info = channel_name;
    
        params.preprocessing = false;
        params.analyze = true;
    
        params.freq_band_to_analyze = fre_bands;
    
        params.detrend = true;

        params.both_time = 2;
    
        % NOR_CalculateAllPower(data_path,time_path,save_path,result_path,file_name,channel_name,true,true,fre_bands, true);
    
        NOR_CalculateAllPower(params.data_dir,params.time_dir,params.save_dir, ...
            params.result_dir,params.sample_name,params.channel_info, ...
            params.preprocessing,params.analyze,params.freq_band_to_analyze,...
            params.detrend, params.both_time);
            
        % NOR_CalculateAllPower(data_path, params);
        disp(strcat('Done: ', file_name, '--', channel_name))
    end
end
%% heatmap

