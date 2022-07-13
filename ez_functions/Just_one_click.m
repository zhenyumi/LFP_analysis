%% Set environment
clc;close all;clear;

% Please set the path correctly !!!
% Please set the 'LFP' folder as the working dir, or add the 'LFP' folder
%   and its subfolders into the MATLAB sesarch path

%Import script files (The script file needed)
addpath(genpath('LFP/Scripts/'));
%Set data path (The path of .nex5 file)
data_path = 'LFP/Data/nex5/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month without LED training/15 month without LED training_NEX5 and video/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/15 month with 40Hz LED training/';
% data_path = '/Volumes/Seagate Basic/LFP/code20210409/6 month without light training/6 month without LED training_NEX5 and video/';
addpath(data_path);
%Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
time_path = 'LFP/Data/time_intervals/seg_results/';
%Set path of saved processed data (The path to save processed file)
% save_path = 'LFP/Data/preprocessed_data/';
save_path = '/Volumes/Seagate Basic/LFP/LFP/Data/preprocessed_data/';
%Set path to save the result calculated
result_path = 'LFP/Data/results/seg_trapz/';
%Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
file_name = 'MV791-4-18-1';
channel_name = 'FP13';
% Load data

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
% Data filtering - Notch filter and bandpass filter
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
% Denoising/Detrending (Optional)
d_fs = 10; %Sampling frequency for detrending process
d_movwin = [.5 .1]; %Moving window for detrending process

dLFP = locdetrend(data,d_fs,d_movwin);

disp('Detrending done');
clear d_fs d_movwin;
% Save data as .mat
save([save_path file_name '_' channel_name '.mat'], 'data', 'fs');
% save('','data','fs');
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
% Calculate PSD (No moving window)
% S: the estimated spectrum; 
% f: the frequencies of estimation; the confidence band (p<0.05)
% Note for *S*: the first dimension being the power in different frequencies,
%   the second dimension being the trial or channel. The second dimension is
%   1 when the user requests a spectrum that is averaged over the trials or channels
% [S,f,Serr]=mtspectrumc(data,params)

params.tapers=[3 5];
params.Fs=fs;
params.err = [1 0.05];
params.fpass = [.1 100]; % Just calculate 0.1-100Hz

data_size = size(seg_data);
psds = {};
freqs = {};
Serrs = {};

for i = 1:data_size(2)
    data = seg_data{i}; % class: double
    [S,f,Serr]=mtspectrumc(data,params);
    % class: double → cell
    psds{i} = S; 
    freqs{i} = f;
    Serrs{i} = Serr;
end

clear data f S Serr i data_size;
disp('PSD calculated');
% Calculate absolute power of selected freqency band
% When setting the frequency band, make sure the first item is the overall
%   frequency band (which is the denominator when calculating relative power)
band_freq = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ];
data_size = size(psds);
abs_powers = {}; % Data to save
abs_powers_tmp = {}; % Data for subsequent computation

for i = 1:data_size(2)
    S = psds{i};
    f = freqs{i};
    tmp_power = [];
    for j = 1:length(band_freq(:,1))
        freq_band = [band_freq(j,1) band_freq(j,2)];
        power = inte_by_freq(S, f, freq_band, 'trapz');
        abs_powers{i,j} = abs(power); 
        tmp_power(end+1) = abs(power);
    end
    abs_powers_tmp{i} = tmp_power; 
end

clear S f tmp_power i j power freq_band data_size
% Calculate relative power
rel_powers = {}; % Data to save

for i = 1:length(abs_powers_tmp)
    for j = 1:length(abs_powers_tmp{i})
        rel_powers{i, j} = abs_powers_tmp{i}(j)/abs_powers_tmp{i}(1);
    end
end

clear i j abs_powers_tmp
% Save data
target_freq_band = {};
for i = 1:length(band_freq)
    if i == 1
        tmp_str = [mat2str(band_freq(i,1)) '-' mat2str(band_freq(i,2)) ' (Overall)'];
    else
        tmp_str = [mat2str(band_freq(i,1)) '-' mat2str(band_freq(i,2))];
    end
    target_freq_band{i} = tmp_str;
end
clear tmp_str i

% Absolute power
table_abs_power = cell2table(abs_powers);
table_abs_power.Properties.VariableNames = target_freq_band;

% Relative power
table_rel_power = cell2table(rel_powers);
table_rel_power.Properties.VariableNames = target_freq_band;

% psds
table_psds = {};
for i = 1:length(psds)
    for j = 1:length(psds{i})
        table_psds{i, j} = psds{i}(j);
    end
end
clear i j psds
table_psds = cell2table(table_psds'); % Note: Here is a transpose

% Frequencies corresponding to psd (each segment)
table_freq = {};
for i = 1:length(freqs)
    for j = 1:length(freqs{i})
        table_freq{i, j} = freqs{i}(j);
    end
end
clear i j freqs
table_freq = cell2table(table_freq');

% Errors calculated corresponding to psd
table_serr = {};
for i = 1:length(Serrs)
    for j = 1:length(Serrs{i})
        table_serr{i, j} = Serrs{i}(j);
    end
end
clear i j Serrs
table_serr = cell2table(table_serr');
% Save as .xlsx
name_xlsx = [result_path file_name '_' channel_name '.xlsx'];
writetable(table_rel_power, name_xlsx, "Sheet", 'relative power');
writetable(table_abs_power, name_xlsx, "Sheet", 'absolute power');
writetable(table_psds, name_xlsx, "Sheet",'psds');
writetable(table_freq, name_xlsx, "Sheet", 'frequencies');
writetable(table_serr, name_xlsx, "Sheet", 'errors calculated');

disp('Data saved');