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
sheet = inputdlg({'sheet number(1,2,...):'},'sheet'); % 选择读哪个sheet
input_sheet = str2num(sheet{1}); % 转成数字
%%读取时间表
fullpath = strcat(path,file);
time_table = xlsread(fullpath, input_sheet, 'B2:C1000');% 读取时间表
num_timeset = size(time_table,1); % 计算有多少个时间段
%%MI保存的文件名
filename_temp = inputdlg({'MI_filename(1,2,...):'},'filename'); % 输入文件名，用于保存power spectrum

for jjj = 1:2
    if jjj == 1
        phase_freqs = [4:1:8];
        amp_freqs = [30:2:50]; 
        filename_mi_1 = ['MI_',filename_temp{1},'_lowgamma_bar','.xlsx']; % MI保存文件fullpath
        filename_mi_2 = ['MI_',filename_temp{1},'_lowgamma_max','.xlsx']; % MI保存文件fullpath
        filename_mi_3 = ['MI_',filename_temp{1},'_lowgamma_mimatrix_sheet',sheet{1},'.xlsx']; % MI保存文件fullpath
    else
        phase_freqs = [4:1:8];
        amp_freqs = [50:2:80];
        filename_mi_1 = ['MI_',filename_temp{1},'_highgamma_bar','.xlsx']; % MI保存文件fullpath
        filename_mi_2 = ['MI_',filename_temp{1},'_highgamma_max','.xlsx']; % MI保存文件fullpath
        filename_mi_3 = ['MI_',filename_temp{1},'_highgamma_mimatrix_sheet',sheet{1},'.xlsx']; % MI保存文件fullpath
    end
    %% 计算MI
    bandw=16;
    filt_order=4;
    surr_N = 200;
    amp_plot_tosave=[];
    mi_max_tosave = [];
    mi_mean_tosave = [];
    zscore_tosave = {};
    raw_tosave = {};
    for i = 1:num_timeset % num_subdata段数据，即循环次数！
        %%截取数据
        s_t = time_table(i,1); % 起始时间
        e_t = time_table(i,2); % 终止时间
        fward=s_t*fs+1;
        bward=e_t*fs;
        sig=FP(fward:bward,1); % 读取s_t-s_t秒、1个通道的数据，FP是一列
        Fs = fs; 
        %%preprocessing
        sig = detrend(sig);
        sig = sig - mean(sig);
        params.Fs=Fs;
        sig = rmlinesc(sig,params,2,'n',50);
        sig=highpassfilter_jie(sig,Fs,1);

        for phase = 1:length(phase_freqs)
            filt = bandpassfilter_jie(sig',Fs,[phase_freqs(phase)-1 phase_freqs(phase)+1],filt_order, 'but');
            hil_pha = hilbert(filt);
            phase_filtered(phase,:)=angle(hil_pha);
        end

        for ampli = 1:length(amp_freqs)
            filt = bandpassfilter_jie(sig',Fs,[amp_freqs(ampli)-bandw amp_freqs(ampli)+bandw],filt_order, 'but');
            hil_amp = hilbert(filt);
            amp_filtered(ampli,:)=abs(hil_amp);
        end

        for phase = 1:length(phase_freqs)
            for ampli = 1:length(amp_freqs)
                phase_data = phase_filtered(phase,:);
                amp_data = amp_filtered(ampli,:);
                data_pac = [phase_data; amp_data];
                [MI,~] = calc_MI_tort(data_pac);
                MI_matrix_raw(ampli,phase) = MI;
            end 
        end
    %     plot_comod(phase_freqs,amp_freqs, MI_matrix_raw);
%         figure; imagesc(phase_freqs,amp_freqs, MI_matrix_raw);
        colorbar; colormap(jet);axis xy; axis tight;
        xlabel('Phase(Hz)');ylabel('Amplitude(Hz)');
        raw_tosave{i}= MI_matrix_raw;
    %     z = interp2(MI_matrix_raw,3);% 插值点数：2^2-1=3
    %     x = linspace(phase_freqs(1), phase_freqs(end), size(z, 2));
    %     y = linspace(amp_freqs(1), amp_freqs(end), size(z, 1));

        %% surrogate analysis
        for surr = 1:surr_N
            for phase = 1:length(phase_freqs)
                for ampli = 1:length(amp_freqs)
                    phase_data_surr = phase_filtered(phase,:);
                    amp_data_surr = shuffle_jie(amp_filtered(ampli,:),Fs);
                    data_pac_surr = [phase_data_surr; amp_data_surr];
                    [MI,~] = calc_MI_tort(data_pac_surr);
                    MI_matrix_surr(surr,ampli,phase) = MI;
                end 
            end   
        end
        mean_surr = squeeze(mean(MI_matrix_surr,1));
        std_surr = squeeze(std(MI_matrix_surr,1));
        MI_matrix_zscore = (MI_matrix_raw - mean_surr)./std_surr;
        MI_matrix_zscore(find(MI_matrix_zscore<1.96))=0;
%         figure; imagesc(phase_freqs,amp_freqs, MI_matrix_zscore);
    %     mi_mean_tosave(:,i) = mean(mean(MI_matrix_zscore));
        colorbar; colormap(jet);axis xy; axis tight;
        xlabel('Phase(Hz)');ylabel('Amplitude(Hz)');
        zscore_tosave{i}=MI_matrix_zscore;
        %% Mi最大处的相幅plot
        [a,b]=find(MI_matrix_zscore == max(max(MI_matrix_zscore)));
        phase_data_plot = phase_filtered(b,:);
        amp_data_plot = amp_filtered(a,:);
        data_pac_plot = [phase_data_plot; amp_data_plot];
        [mi_max,MeanAmp] = calc_MI_tort(data_pac_plot);
        amp_plot_temp = [MeanAmp,MeanAmp]/sum(MeanAmp);
%         figure
%         bar(10:20:720,amp_plot_temp)
%         xlim([0 720])
%         set(gca,'xtick',0:360:720)
%         xlabel('Phase (Deg)')
%         ylabel('Amplitude')

    %     mi_max_tosave(:,i) = max(max(MI_matrix_zscore));
       if size(a,1) ~= 1 || size(a,1) ~= 1
           mi_max_tosave(:,i) = NaN;
           amp_plot_tosave(:,i) =  zeros(36,1);
       else
           mi_max_tosave(:,i) = MI_matrix_raw(a,b);
           amp_plot_tosave(:,i) =  change_row_to_column(amp_plot_temp);
       end

    end

    %% save data
    xlswrite(filename_mi_1,amp_plot_tosave,str2num(sheet{1}),'A1'); 
    xlswrite(filename_mi_2,mi_max_tosave,str2num(sheet{1}),'A1'); %保存MI max
    % xlswrite(filename_mi_1,mi_mean_tosave,2,'A2'); %保存MI mean
%     xlswrite(filename_mi_1,phase_freqs,3,'A1');
%     xlswrite(filename_mi_1,amp_freqs,3,'A3');

%     for i = 1:num_timeset % num_subdata段数据，即循环次数！
%         xlswrite(filename_mi_3, zscore_tosave{i},i,'A1'); %保存MI矩阵 Z-score
%         xlswrite(filename_mi_3, raw_tosave{i},i,'A50'); %保存MI矩阵raw
%     end
    
end