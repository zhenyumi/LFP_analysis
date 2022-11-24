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
time_path = '/Users/zhangzhenzhen/Library/CloudStorage/OneDrive-共享的库-Onedrive/Code/MATLAB/LFP/Data/time_intervals/NOR_Stay_time_intervals/';
%Set path of saved processed data (The path to save processed file)
save_path = '/Volumes/Seagate Basic/LFP/LFP/NOR_preprocessed_data/';
%Set path of folder to save the result calculated
result_path = '/Volumes/Seagate Basic/LFP/Results/NOR/Stay/';

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

% 6m no training (No "3710-10-30-1"), lack 3716-11-26-1
%subject_names = ["1532-4-21-1","1533-4-21-1","1534-4-21-1","3709-11-12-1"];
%result_path = strcat(result_path, '/6m_no_LED/');

% 6m with training (lack "3712-10-30-1")
%subject_names = ["309-5-28-1","314-5-28-1","1882-5-28-1","1897-5-28-1","3715-11-12-1"];
%result_path = strcat(result_path, '/6m_with_LED/');

% 15m no training (lack "3736-10-30-1")
%subject_names = ["3731-11-12-1","MV794-4-21-1","MV791-4-21-1","MV797-4-21-1"];
%result_path = strcat(result_path, '/15m_no_LED/');

% 15m with training (no "3737-10-30-1")
subject_names = ["308-5-28-1","316-5-28-1","319-5-28-1","3732-11-12-1"];
result_path = strcat(result_path, '/15m_with_LED/');

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
%% Others
subject_names = ["1897-5-28-1","3715-11-12-1"];
preprocess = true;
data_path = '/Volumes/Seagate Basic/LFP/LFP/data/code20210409/新型物体识别/6 month with 40Hz LED training/6 month with 40 Hz LED training_NEX5/';