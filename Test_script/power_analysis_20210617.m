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
FP = list{channel,1}.data;% ��Ҫ����ͨ��������
%%%%%%%%%%%%������%%%%%%%%%%%%%%
% P = 40;%����������
% fs=fs/P;%�����ʽ���
% Nt=length(FP);
% FP= FP(1:P:Nt);%�������������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ��ȡExcel
[file,path] = uigetfile( ...
{...
'*.xlsx','Excel (*.xlsx)'; ...
'*.xls','Excel (*.xls)'; ...
'*.*',  'All Files (*.*)'                                                                            
}, ...                  % ������
'Select a Excel File',...     % ����
'MultiSelect', 'off'...  % ��ѡ
);
%%ѡ��sheet
input_sheet = inputdlg({'sheet number(1,2,...):'},'sheet'); % ѡ����ĸ�sheet
input_sheet = str2num(input_sheet{1}); % ת������
%power spectrum ������ļ���
filename_temp = inputdlg({'filename_ps(1,2,...):'},'filename'); % �����ļ��������ڱ���power spectrum
filename_ps = strcat(filename_temp{1},'.xlsx'); % power spectrum�ļ���
%��ȡʱ���
fullpath = strcat(path,file);
time_table = xlsread(fullpath, input_sheet, 'B2:C1000');% ��ȡʱ���
num_timeset = size(time_table,1); % �����ж��ٸ�ʱ���
[~,ind] = max(time_table(:, 2) - time_table(:, 1)); % ʱ������Ƕ�(ind)

%% 1.����power spectrum��2.����spectrogram����ͼ��
for i = 1:num_timeset % num_subdata�����ݣ���ѭ��������
    %%��ȡ����
    s_t = time_table(i,1); % ��ʼʱ��
    e_t = time_table(i,2); % ��ֹʱ��
    fward=s_t*fs+1;
    bward=e_t*fs;
    sig=FP(fward:bward,1); % ��ȡs_t-s_t�롢1��ͨ�������ݣ�FP��һ��
    Fs =fs; % ����Ƶ��
 
    %%preprocessing
    sig = detrend(sig);
    sig = sig - mean(sig);
    params.Fs=Fs;
    sig = rmlinesc(sig,params,1.5,'n',50);%n:����ͼ��y����ͼչʾ
    sig=highpassfilter_jie(sig,Fs,1);
    
    %%power spectrum
     %###########################
    params.tapers=[3 5];
     %###########################
    [Sps,fps] = mtspectrumc(sig,params); % power spectrum ��params.tapers=[1 1];Ĭ��ֵ��[3,5]
    
    %%power
%     figure
%     plot_vector(Sps,fps);%%plot_vector ȡ�˶���,�˴���Ϊչʾ�ã�û��ͳһ����
%     axis([0 120 0 80])
    Sps_to_write{i} = Sps;
    fps_to_write{i} = fps;

    %%spectrogram(��ͼ)
    %###########################
    movingwin=[1000/Fs, 1/Fs]; % ��λ��S(����200��ʾ�������Ŀ�ȣ���������2��ʾ������������)
    %###########################
    [Ssg,tsg,fsg] = mtspecgramc(sig, movingwin, params);
%     plot_mtspecgram(Ssg./(sum(sum(Ssg))),tsg,fsg,[0,80]);%
    
end

%% 3.bandpower
%%ͳһ���ȣ�ת����psd
 %###########################################
band_Fre = [4,8;8,12;12,30;30,50;50,80;39,41];% ��ͬƵ�εķ�Χ
 %############################################
band_power = zeros(num_timeset,size(band_Fre,1)); % ��bandpower
for i = 1:num_timeset 
    Sps_temp = interp1(fps_to_write{i},Sps_to_write{i},fps_to_write{ind});%%ͳһ����
    Spsd_to_calc{i}= Sps_temp/(0.5*Fs/(length(fps_to_write{ind})-1));%ת����psd������df��
end

%%calcu band power
for i = 1:num_timeset
    for j = 1:size(band_power,2)
        fmin = band_Fre(j,1); 
        fmax = band_Fre(j,2); % ���±߽磬 ��delta��1-3Hz
        band_power(i,j)=bandpower(Spsd_to_calc{i},fps_to_write{ind},[fmin fmax], 'psd');%%��psd��bandpower
    end
end
band_power=band_power./sum(band_power(:,1:5),2);
%%д��excel
xlswrite(fullpath,band_power,input_sheet,'D2');

% 4.����power spectrum��ͳһ���Ȳ�ȡlog��
%ͳһ���ȣ�ȡ���������Ա�׼
for i = 1:num_timeset 
    Sps_to_excel{i} = interp1(fps_to_write{i},10*log10(Sps_to_write{i}),fps_to_write{ind});
    Sps_to_excel{i} = interp1(fps_to_write{i},Sps_to_write{i},fps_to_write{ind});
end

%norm 
[~,aa]=min(abs(fps_to_write{ind}-90));
for i = 1:num_timeset   
    Sps_to_excel{i} =  80 + 10*log10(Sps_to_excel{i}(1:aa)/sum(Sps_to_excel{i}(1:aa)));
end

%д��Excel
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

%%��ͼz���ͬһ������
% set(gca, 'CLim', [0 3.5e-5]);
% axis off;

