%% Set environment
clc;close all;clear;

% !!! Please set the path correctly !!!
% You can set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path
% !!! If MATLAB does not find the folder, you should create that folder
%       manually

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of folder that contains .nex5 file)
data_path = 'folder that contain .nex5 file';
addpath(data_path);
%Set the path of folder that records time interbals 
%   (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/1s_time_intervals/';
%Set path of saved processed data (The path to save processed file)
save_path = 'folder to save the preprocessed .mat data';
%Set path of folder to save the result calculated
result_path = 'folder to save the analyze result';

% The frequency bands that want to analyze, the first band should be the "overall band"
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
% If this variable was set to *true*, then the script will begin from the
% original .nex5 file, and perform the preprocessing, then a .mat file will
% be saved to the save_path
preprocess = true; % true or false
% If this variable was set to *true*, the data will be detrended during the
% preprocessing process
detrend = false; % true or false
% If this variable was set to *true*, the script will begin from the
% preprocessed data, and no preprocessing will be performed
analyze = true; % true or false
% Use *readtable* function or not, this may be a problem in some version
% of MATLAB
use_readtable = true;

% The channels that want to analyze
%   Note: If you want to analyze specific channel, you can set this
%   variable as ["Channel 1" "Channel 2"]
%   !!! Please use double quotation marks and separate with spaces !!!
channel_names = ["FP04" "FP05" "FP12" "FP13"];
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = 'filename';

% !!! You should change the file_name each time, when you change the 
% subject to analyze !!!
for channel_name = channel_names
    disp(channel_name);
    CalculateAllPower(data_path,time_path,save_path,result_path,file_name,...
        channel_name,preprocess,analyze,fre_bands,detrend,use_readtable);
    disp(strcat('Done: ', file_name, '--', channel_name))
end
%% LOOP
clc;close all;clear;

% !!! Please set the path correctly !!!
% You can set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path
% !!! If MATLAB does not find the folder, you should create that folder
%       manually

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of folder that contains .nex5 file)
data_path = 'folder that contain .nex5 file';
addpath(data_path);
%Set the path of folder that records time interbals 
%   (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/1s_time_intervals/';
%Set path of saved processed data (The path to save processed file)
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
%Set path of folder to save the result calculated
result_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/results/OFT_powers/';

% The frequency bands that want to analyze, the first band should be the "overall band"
fre_bands = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ; 39,41];
% If this variable was set to *true*, then the script will begin from the
% original .nex5 file, and perform the preprocessing, then a .mat file will
% be saved to the save_path
preprocess = false; % true or false
% If this variable was set to *true*, the data will be detrended during the
% preprocessing process
detrend = false; % true or false
% If this variable was set to *true*, the script will begin from the
% preprocessed data, and no preprocessing will be performed
analyze = true; % true or false
% use *readtable* or not
use_readtable = true;

% The channels that want to analyze
%   Note: If you want to analyze specific channel, you can set this
%   variable as ["Channel 1" "Channel 2"]
%   !!! Please use double quotation marks and separate with spaces !!!
channel_names = ["FP04" "FP05" "FP12" "FP13"];
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)

% 6m x Tranining x LED
%subject_names = ["1532-4-18-1","1533-4-18-1","1534-4-18-1","3709-11-10-1","3716-11-24-1"];
%result_path = strcat(result_path, '/6m_without_LED/');

% 15m x Tranining x LED
%subject_names = ["3731-11-10-1","3892-11-24-1","MV791-4-18-1","MV794-4-18-1","MV797-4-18-1"];
%result_path = strcat(result_path, '/15m_without_LED/');

% 6m √ Tranining x LED
%subject_names = ["309-5-26-1","314-5-26-1","1882-5-26-1","1897-5-26-1","3715-11-10-1", "3717-11-24-1"];
%result_path = strcat(result_path, '/6m_with_LED/');

% 15m √ Tranining x LED
subject_names = ["308-5-26-1","316-5-26-1","318-5-26-1","319-5-26-1","3732-11-10-1", "3891-11-24-1"];
result_path = strcat(result_path, '/15m_with_LED/');

% 6m x Tranining √ LED
%subject_names = ["1532-4-18-2","1533-4-18-2","1534-4-18-2","3709-11-10-2","3716-11-24-2"];
%result_path = strcat(result_path, '/6m_without_LED_2/');

% 15m x Tranining √ LED
% subject_names = ["3731-11-10-2","3892-11-24-2","MV791-4-18-2","MV794-4-18-2","MV797-4-18-2"];
% result_path = strcat(result_path, '/15m_without_LED_2/');

% 6m √ Tranining √ LED
%subject_names = ["309-5-26-2","314-5-26-2","1882-5-26-2","1897-5-26-2","3715-11-10-2", "3717-11-24-2"];
%result_path = strcat(result_path, '/6m_with_LED_2/');

% 15m √ Tranining x LED
%subject_names = ["308-5-26-2","316-5-26-2","318-5-26-2","319-5-26-2","3732-11-10-2", "3891-11-24-2"];
%result_path = strcat(result_path, '/15m_with_LED_2/');

if ~exist(result_path, 'dir')
    mkdir(result_path);
end


% !!! You should change the file_name each time, when you change the 
% subject to analyze !!!
for file_name = subject_names
    for channel_name = channel_names
        disp(channel_name);
        CalculateAllPower(data_path,time_path,save_path,result_path,file_name,...
            channel_name,preprocess,analyze,fre_bands,detrend,use_readtable);
        disp(strcat('Done: ', file_name, '--', channel_name))
    end
end