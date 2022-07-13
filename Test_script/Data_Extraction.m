clc;close all;clear;

% !!! Please set the path correctly !!!
% You can set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path
% !!! If MATLAB does not find the folder, you should create that folder
%       manually

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of folder that contains .nex5 file)
data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';

file_name = "1532-4-18-1";
%%
file = readNex5File(strcat(data_path, file_name, '.nex5'));
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
%%
size_LFP = size(up_data);
size_sp = size(spike_data);
len = min(size_LFP(1),size_sp(1));
datalfp = up_data(1:100000);
datasp = spike_data(1:100000);

params.Fs=40000;
params.fpass=[0 100];
params.tapers=[10 19];
params.trialave=1;
params.err=[1 0.05];
[C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencycpt(datalfp,datasp,params);

plot(f, C)
%%
params.Fs=40000;
params.fpass=[0 100];
params.tapers=[10 19];
params.trialave=0;
params.err=[1 0.05];
movingwin = [0.5 0.02];
[C,phi,S12,S1,S2,f,zerosp,confC,phistd]=coherencycpt(datalfp,datasp,params);
% [C,phi,S12,S1,S2,f,zerosp,confC,phistd]=cohgramc(LFP_all{1},sp_all{1},movingwin,params);