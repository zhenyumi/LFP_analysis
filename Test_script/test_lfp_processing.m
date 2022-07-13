ccc
cd '/media/data/data/test/LFP-test';
file = readNex5File();
list = file.contvars;
StringList = [""];
for i = 1:length(list)
    StringList = [StringList;list{i,1}.name];
end
StringList = StringList(2:end);
channel = listdlg('ListString',StringList);
fs = list{channel,1}.ADFrequency;
FP = list{channel,1}.data;% ��Ҫ����ͨ��������
data = FP;
save('test-data.mat', 'data', 'fs');

%% downsample
ccc; cd /media/data/data/test/LFP-test;
load('test-data.mat', 'data', 'fs');
ts = (1:length(data))/fs;

data = data(1:5:end);
ts = ts(1:5:end);
fs = 200;
save('test-downsampled-data', 'ts', 'fs', 'data');


%% delta, theta, 100, 
ccc; cd /media/data/data/test/LFP-test;
load('test-downsampled-data', 'ts', 'fs', 'data');

[X,xtick] = ezfft(data, fs, 'log');
%%
figure;
[XX, t, f] = ezspectrogram(data, fs); hold on;
%imagesc(t,f,10*log10(XX)'); axis xy;% colorbar;
h = plot(ts, data*300+50, 'color', 'w');

%% 
figure;
movingwin = [1, 0.25];
params.Fs = fs;
if exist('fpass', 'var')
    params.fpass = [2, 50];
end
data = data - mean(data);
[XX, t, f] = mtspectrogram(data, movingwin, params);
% figure;
imagesc(t,f,10*log10(XX)'); axis xy;% colorbar;

%% phase amplitude coupling
% bandpass, theta, [8, 12], delta [1 4]
% hilbert
% complex number, phase

% phase, amplitude()

%



