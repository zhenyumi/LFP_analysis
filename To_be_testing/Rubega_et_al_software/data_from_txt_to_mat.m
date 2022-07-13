% Thanks to this script it's possible to convert file.txt (containing data) into files.mat
% The file.mat will contain a matrix RAT (number of samples x number of
% sweeps), a vector new_time (number of samples x 1) and a struct
% parameters (parameters.dT=sampling step; parameters.Fs=sampling frequency; parameters.Ns=number of samples for each sweep)

%% Cleaning up workspace

clc; clear all; close all;

%% Choosing file.mat name to save data

prompt = {'Choose file.mat name to save data'};
dlg_title = 'Input';
num_lines = 1;
def = {'test_data.mat'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

name=answer{1}; 

%% Files loading

[files,path]=uigetfile('.txt','Select files','MultiSelect','off');
 
%% Signal features: sampling frequency, time vector

X=load(fullfile(path,files)); 
[~,Nf]=size(X);

time=X(:,1);
dT=time(2)-time(1);     % sampling step [s]
Fs=1/dT;                % sampling frequency [Hz]
Ns=length(time);        % number of samples

parameters = struct('dT',dT,'Fs',Fs,'Ns',Ns);
    
%% Time of stimulation set to 0

prompt = {'Insert time of stimulation [s] (it will be set to 0)'};
dlg_title = 'Input';
num_lines = 1;
def = {'0.15'};
answer1 = inputdlg(prompt,dlg_title,num_lines,def);

Tstim=str2double(answer1{1});
t1=find(time>=Tstim,1,'first'); 
new_time=(0:dT:time(end)-time(t1))*1000; % time in ms

%% .mat creation

RAT=zeros(length(new_time),Nf-1); % matrix containing in each column the data related to one sweep 
 
 for i=2:Nf     
    RAT(:,i-1)=(X(t1:end,i)*1000); % data in mV
 end
 
%% Saving data

save(name,'RAT','new_time','parameters') 
