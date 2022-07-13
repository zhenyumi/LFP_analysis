%% Set environment
clc;close all;clear all;

% Please set the path correctly !!!
% Please set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of .nex5 file)
data_path = 'LFP/Data/nex5/';
addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/';
%Set path to save processed data (The path to save processed file)
save_path = 'LFP/Data/preprocessed_data/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = '1532-4-18-1';
channel_name = 'FP04';
%% Load data

% Modify this part using your own ways
% Make sure load the following two variables:
%   1. data: The recorded data to be analyzed
%   2. fs: The sampling frequency

file = readNex5File([data_path file_name '.nex5']);
list = file.contvars;
StringList = [""];
for i = 1:length(list)
    StringList = [StringList;list{i,1}.name];
end
StringList = StringList(2:end);
channel = listdlg('ListString',StringList);
fs = list{channel,1}.ADFrequency;
%Select the channel to be analyzed
FP = list{channel,1}.data;
data = FP;

disp('Data loaded')
%% Down sampling to 200Hz (Optional)
fs_old = fs;

ts = (1:length(data))/fs;
data = data(1:5:end);
ts = ts(1:5:end);
fs = 200;

formatstr = 'Data down-sampled from %d to %d Hz\n';
fprintf(formatstr,fs_old,fs);

clear fs_old;
%% Data filtering - Notch filter and bandpass filter
% Notch filter (49-51 Hz)
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',fs);
% fvtool(d,'Fs',fs) % Visualize the notch filter
n_data = filtfilt(d, data);
data = n_data;
clear n_data;
disp('Notch filtering done')

% Band pass filter (0.1-100 Hz)
f_data = bandpass(data,[.1 100],fs);
data = f_data;
clear f_data;

disp('band pass filtering done')
%% Denoising/Detrending (Optional)
d_fs = 10; %Sampling frequency for detrending process
d_movwin = [.5 .1]; %Moving window for detrending process

dLFP = locdetrend(data,d_fs,d_movwin);

disp('Detrending done');
clear d_fs d_movwin;
%% Save data as .mat
save([save_path file_name '_' channel_name '.mat'], 'data', 'fs');
% save('','data','fs');