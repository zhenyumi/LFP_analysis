%% analysis by chronux toolbox
clc;close all;clear all
addpath('Nex5RDR');

%% load data
file = readNex5File();
list = file.contvars;
StringList = [""];
for i = 1:length(list)
    StringList = [StringList;list{i,1}.name];
end
StringList = StringList(2:end);
channel = listdlg('ListString',StringList);
fs = list{channel,1}.ADFrequency;
FP = list{channel,1}.data;% 需要分析通道的数据
%%%%%%%%%%%%降采样%%%%%%%%%%%%%%
% P = 40;%降采样倍数
% fs=fs/P;%采样率降低
% Nt=length(FP);
% FP= FP(1:P:Nt);%降采样后的数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 读取Excel
[file,path] = uigetfile( ...
{...
'*.xlsx','Excel (*.xlsx)'; ...
'*.xls','Excel (*.xls)'; ...
'*.*',  'All Files (*.*)'                                                                            
}, ...                  % 过滤器
'Select a Excel File',...     % 标题
'MultiSelect', 'off'...  % 多选
);
%%选择sheet
input_sheet = inputdlg({'sheet number(1,2,...):'},'sheet'); % 选择读哪个sheet
input_sheet = str2num(input_sheet{1}); % 转成数字
%power spectrum 保存的文件名
filename_temp = inputdlg({'filename_ps(1,2,...):'},'filename'); % 输入文件名，用于保存power spectrum
filename_ps = strcat(filename_temp{1},'.xlsx'); % power spectrum文件名
%读取时间表
fullpath = strcat(path,file);
time_table = xlsread(fullpath, input_sheet, 'B2:C1000');% 读取时间表
num_timeset = size(time_table,1); % 计算有多少个时间段
[~,ind] = max(time_table(:, 2) - time_table(:, 1)); % 时间最长的那段(ind)

%% 1.分析power spectrum；2.分析spectrogram（热图）
for i = 1:num_timeset % num_subdata段数据，即循环次数！
    %%截取数据
    s_t = time_table(i,1); % 起始时间
    e_t = time_table(i,2); % 终止时间
    fward=s_t*fs+1;
    bward=e_t*fs;
    sig=FP(fward:bward,1); % 读取s_t-s_t秒、1个通道的数据，FP是一列
    Fs =fs; % 采样频率
 
    %%preprocessing
    sig = detrend(sig);
    sig = sig - mean(sig);
    params.Fs=Fs;
    sig = rmlinesc(sig,params,1.5,'n',50);%n:不画图，y：画图展示
    sig=highpassfilter_jie(sig,Fs,1);
    
    %%power spectrum
     %###########################
    params.tapers=[3 5];
     %###########################
    [Sps,fps] = mtspectrumc(sig,params); % power spectrum ：params.tapers=[1 1];默认值是[3,5]
    
    %%power
%     figure
%     plot_vector(Sps,fps);%%plot_vector 取了对数,此处仅为展示用，没有统一长度
%     axis([0 120 0 80])
    Sps_to_write{i} = Sps;
    fps_to_write{i} = fps;

    %%spectrogram(热图)
    %###########################
    movingwin=[1000/Fs, 1/Fs]; % 单位：S(这里200表示窗函数的宽度（点数），2表示步长（点数）)
    %###########################
    [Ssg,tsg,fsg] = mtspecgramc(sig, movingwin, params);
%     plot_mtspecgram(Ssg./(sum(sum(Ssg))),tsg,fsg,[0,80]);%
    
end

%% 3.bandpower
%%统一长度，转换成psd
 %###########################################
band_Fre = [4,8;8,12;12,30;30,50;50,80;39,41];% 不同频段的范围
 %############################################
band_power = zeros(num_timeset,size(band_Fre,1)); % 存bandpower
for i = 1:num_timeset 
    Sps_temp = interp1(fps_to_write{i},Sps_to_write{i},fps_to_write{ind});%%统一长度
    Spsd_to_calc{i}= Sps_temp/(0.5*Fs/(length(fps_to_write{ind})-1));%转换成psd（除以df）
end

%%calcu band power
for i = 1:num_timeset
    for j = 1:size(band_power,2)
        fmin = band_Fre(j,1); 
        fmax = band_Fre(j,2); % 上下边界， 如delta波1-3Hz
        band_power(i,j)=bandpower(Spsd_to_calc{i},fps_to_write{ind},[fmin fmax], 'psd');%%用psd求bandpower
    end
end
band_power=band_power./sum(band_power(:,1:5),2);
%%写入excel
xlswrite(fullpath,band_power,input_sheet,'D2');

% 4.保存power spectrum（统一长度并取log后）
%统一长度，取对数，除以标准
for i = 1:num_timeset 
    Sps_to_excel{i} = interp1(fps_to_write{i},10*log10(Sps_to_write{i}),fps_to_write{ind});
    Sps_to_excel{i} = interp1(fps_to_write{i},Sps_to_write{i},fps_to_write{ind});
end

%norm 
[~,aa]=min(abs(fps_to_write{ind}-90));
for i = 1:num_timeset   
    Sps_to_excel{i} =  80 + 10*log10(Sps_to_excel{i}(1:aa)/sum(Sps_to_excel{i}(1:aa)));
end

%写入Excel
data_to_write=[];
for i = 1:num_timeset+1 
    if i == 1
        data_to_write(:,i) = change_row_to_column(fps_to_write{ind}(1:aa));  
%         data_to_write(:,i) = change_row_to_column(fps_to_write{ind});
    else
        data_to_write(:,i) = change_row_to_column(Sps_to_excel{i-1});   
    end
end
fullpath_ps=strcat(path,filename_ps);
xlswrite(fullpath_ps,data_to_write,input_sheet);   

%%热图z轴的同一化代码
% set(gca, 'CLim', [0 3.5e-5]);
% axis off;

