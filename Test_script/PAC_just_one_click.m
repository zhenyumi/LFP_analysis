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
time_path = 'LFP/Data/time_intervals/seg_results/';
%Set path to save processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
% Save figure path
figure_path = 'LFP/Data/figures/PAC/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = '1532-4-18-2';
channel_name = 'FP13';
% Load data
% Modify this part using your own ways
% Make sure load the following two variables:
%   1. data: The recorded data to be analyzed
%   2. fs: The sampling frequency

load([save_path file_name '_' channel_name '.mat'], 'data', 'fs');

disp('Data loaded');
% Segmentation
times = readtable([time_path file_name '.xlsx']);
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

disp('Segmentation done')
% test
lfp = [];
for i = 1:length(seg_data)
    lfp = [lfp seg_data{i}']; % * Note: Here is a tranpose
end

data_length = length(lfp);
srate = fs;
dt = 1/srate;
t = (1:data_length)*dt;

% Plotting the signal
%{
clf 
subplot(2,1,1)
plot(t,lfp)
xlim([0 1])
set(gca,'fontsize',14)
xlabel('time (s)')
ylabel('mV')
%}

% Define the amplitude- and phase-frequencies

% PhaseFreqVector=2:2:50;
% AmpFreqVector=10:5:100;
PhaseFreqVector=0:2:100;
AmpFreqVector=0:2:100;

% PhaseFreq_BandWidth=4;
% AmpFreq_BandWidth=20;

PhaseFreq_BandWidth=1;
AmpFreq_BandWidth=1;

% Define phase bins

nbin = 18; % number of phase bins
position=zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbin;
for j=1:nbin 
    position(j) = -pi+(j-1)*winsize; 
end

% Filtering and Hilbert transform
tic
Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii);
    Af2=Af1+AmpFreq_BandWidth;
    AmpFreq=eegfilt(lfp,srate,Af1,Af2); % filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

for jj=1:length(PhaseFreqVector)
    Pf1 = PhaseFreqVector(jj);
    Pf2 = Pf1 + PhaseFreq_BandWidth;
    PhaseFreq=eegfilt(lfp,srate,Pf1,Pf2); % filtering 
    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % getting the phase time series
end
toc
disp('Done CPU filtering');

% Compute MI and comodulogram

counter1=0;
for ii=1:length(PhaseFreqVector)
counter1=counter1+1;

    Pf1 = PhaseFreqVector(ii);
    Pf2 = Pf1+PhaseFreq_BandWidth;
    
    counter2=0;
    for jj=1:length(AmpFreqVector)
    counter2=counter2+1;
    
        Af1 = AmpFreqVector(jj);
        Af2 = Af1+AmpFreq_BandWidth;
        [MI,MeanAmp]=ModIndex_v2(PhaseFreqTransformed(ii, :), AmpFreqTransformed(jj, :), position);
        Comodulogram(counter1,counter2)=MI;
    end
end
toc
disp('Comodulation loop');

% Plot comodulogram

clf;
contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Comodulogram',30,'lines','none');
set(gca,'fontsize',14);
ylabel('Amplitude Frequency (Hz)');
xlabel('Phase Frequency (Hz)');
title([file_name ' ' channel_name]);
caxis([0 25e-4]);
xlim([1 40]);
colorbar;

figure_name = [figure_path file_name '_' channel_name '.png'];
saveas(gca, figure_name);
disp('done')