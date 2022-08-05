function f = NOR_CalculateAllPower(data_dir, time_dir, save_dir, result_dir, ...
    sample_name, channel_info, preprocessing, analyze, freq_band_to_analyze, detrend, ...
    both_time)
% Input: 
%   data_dir: [string] The path containing original data (For example, .nex5 file)
%       %!: This should be the folder path that containing original data
%   time_dir: [string] The path for selected time period or time points (.xlsx file)
%       %!: The time information should be stored in a .xlsx file
%   save_dir: [string] The path to save the preprocessed .mat file
%       %!: If the no preprocessing, this dir should contain the .mat file to
%       analyze
%   result_dir: [string] The folder path to save analyzed results
%   sample_name: [string] The file name of the data to be analyzed 
%       %!: (Example: The sample_name should be "test" if the data was from "test.nex5")
%   channel_info: [list] The channel to be analyzed
%   preprocessing: [Boolean] If true, the preprocessing will be performed
%   analyze: [Boolean] If true, the analyze will be performed
%   freq_band_to_analyze: [list], The frequency band to be analyzed
% Attention: 
%   1. The file name should be consistent. For example, if the original data is 'Subject1.nex5', 
%       the .xlsx file in time_dir should be 'subject1.xlsx'. 
%   2. Besides, for each channel, the preprocessing will be performed seperately, 
%       and save as a .mat file in save_dir. 
%       For example, if channel FP04 is preprocessed, then 'subject1_FP04.mat' file will be saved in the save_dir.
%   3. The analyzed result will be saved into a .xlsx file, whose name will be 'subject_name+channel_name.xlsx'. 
%       Example: subject1_FP04.xlsx



   if(~exist('preprocessing','var'))
        preprocessing = true;
   end
   if(~exist('analyze','var'))
        analyze = true;
   end
   if(~exist('freq_band_to_analyze', 'var'))
       freq_band_to_analyze = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ];
   end
   if(~exist('detrend','var'))
        detrend = false;
   end
   if(~exist('both_time','var'))
        both_time = 1;
   end


    % ! Set environment 
    % clc;close all;clear;

    %Set data path (The path of .nex5 file)
    data_path = data_dir;
    %Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
    time_path = time_dir;
    %Set path of saved processed data (The path to save processed file)
    save_path = save_dir;
    %Set path to save the result calculated
    result_path = result_dir;
    %Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
    file_name = sample_name;
    channel_name = channel_info;
    
    % ! preprocessing

    if preprocessing
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
        
        if detrend
            data = locdetrend(data,d_fs,d_movwin);
        else
            % dLFP = locdetrend(data,d_fs,d_movwin);
        end
        
        disp('Detrending done');
        clear d_fs d_movwin;
        % Save data as .mat
        save_file_path = strcat(save_path, file_name,'_',channel_name,".mat");
        save(save_file_path, 'data', 'fs');
        clear save_file_path
        disp('Preprocessed data saved');
    end

    if analyze
        % ! Perform power analysis
        % clc;close all;clear;
        
        %Set data path (The path of .nex5 file)
        data_path = data_dir;
        %Set the path of recorded time interbals (The .xlsx file which recorded the interested time interval)
        time_path = time_dir;
        %Set path of saved processed data (The path to save processed file)
        save_path = save_dir;
        %Set path to save the result calculated
        result_path = result_dir;
        %Set the name of the file to be loaded (example: file_name = 'test' for test.nex5)
        file_name = sample_name;
        channel_name = channel_info;
        
        load_file_path = strcat(save_path, file_name, '_', channel_name, '.mat');
        load(load_file_path, 'data', 'fs');
        clear load_file_path
    
        disp('Data loaded');

        % Segmentation

        time_data_dir = strcat(time_path, file_name, '.xlsx'); 
        times = readtable(time_data_dir);
        clear time_data_dir

        % The column data in the .xlsx file should be [new old]
        time_order = ["new", "old"];
        voltage_data = data;
        for to = 1:length(time_order)
            time_type = time_order(to);
            target_times = {};
            % Time for new object is the 1st column; for old object is 2nd
            % column
            if strcmp(time_type, "old")
                target_times = table2array(times(:,2));
            elseif strcmp(time_type, "new")
                target_times = table2array(times(:,1));
            end
            % end_times = table2array(times(:,2));
            % clear times;
            
            % pre and post time points
            seg_data_both = {};

            % Remove the NaN in the target_times
            target_times = target_times(~isnan(target_times));

            for i = 1:length(target_times)
                start = target_times(i) - both_time;
                ends = target_times(i) + both_time;
                start_index = round(start*fs+1);
                end_index = round(ends*fs);
                seg_data_both{i} = voltage_data(start_index:end_index);
            end

            %save both_time data
            save_file_path = strcat(save_path,'seg_data_both/',time_type,'/', file_name,'_',channel_name,'_seg',".mat");
            save(save_file_path, 'seg_data_both');
           
            % save('LFP/Data/test_data_seg.mat', "seg_data_both");
    
            % pre time points
            seg_data_pre = {};
            for i = 1:length(target_times)
                start = target_times(i) - 1;
                ends = target_times(i);
                start_index = round(start*fs+1);
                end_index = round(ends*fs);
                seg_data_pre{i} = voltage_data(start_index:end_index);
            end
    
            % post time points
            seg_data_post = {};
            for i = 1:length(target_times)
                start = target_times(i);
                ends = target_times(i) + 1;
                start_index = round(start*fs+1);
                end_index = round(ends*fs);
                seg_data_post{i} = voltage_data(start_index:end_index);
            end
            
            clear start ends i target_times;
    
    
            % Calculate PSD (No moving window) for pre and post data
            % S: the estimated spectrum; 
            % f: the frequencies of estimation; the confidence band (p<0.05)
            % Note for *S*: the first dimension being the power in different frequencies,
            %   the second dimension being the trial or channel. The second dimension is
            %   1 when the user requests a spectrum that is averaged over the trials or channels
            % [S,f,Serr]=mtspectrumc(data,params)
            
    
            %# Show the pre-post heatmap
    
            %#: Analyze the pre and post time periods
            analyze_order = ["pre","post"];
    
            for o = 1:length(analyze_order)
                % order means the pre attach or the post attach
                order = analyze_order(o);
                seg_data = {};
                if strcmp(order, "pre")
                    seg_data = seg_data_pre;
                elseif strcmp(order, "post")
                    seg_data = seg_data_post;
                end
                
                params.tapers=[3 5];
                params.Fs=fs;
                params.err = [1 0.05];
                params.fpass = [.1 100]; % Just calculate 0.1-100Hz
            
                data_size = size(seg_data);
                psds = {};
                freqs = {};
                Serrs = {};
            
                for i = 1:data_size(2)
                    segment_data = seg_data{i}; % class: double
                    [S,f,Serr]=mtspectrumc(segment_data,params);
                    % class: double → cell
                    psds{i} = S; 
                    freqs{i} = f;
                    Serrs{i} = Serr;
                end
            
                clear segment_data f S Serr i data_size;
                disp('PSD calculated');
                % Calculate absolute power of selected freqency band
                % When setting the frequency band, make sure the first item is the overall
                %   frequency band (which is the denominator when calculating relative power)
                % band_freq = [ .1,100; 1,4; 4,8; 8,13; 13,30; 30,50; 50,80 ];
                band_freq = freq_band_to_analyze;
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
                        tmp_str = strcat(mat2str(band_freq(i,1)), '-', mat2str(band_freq(i,2)), ' (Overall)');
                    else
                        tmp_str = strcat(mat2str(band_freq(i,1)), '-', mat2str(band_freq(i,2)));
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
                result_save_folder = "";
                % time_type means the old object or new object
                if strcmp(time_type, "old")
                    result_save_folder = strcat(result_path, "old/");
                elseif strcmp(time_type, "new")
                    result_save_folder = strcat(result_path, "new/");
                end
                % order means the pre attach or post attach
                if strcmp(order, "pre")
                    result_save_folder = strcat(result_save_folder, "pre/");
                elseif strcmp(order, "post")
                    result_save_folder = strcat(result_save_folder, "post/");
                end

                name_xlsx = strcat(result_save_folder, file_name, '_', channel_name, '_', order , '.xlsx');
                writetable(table_rel_power, name_xlsx, "Sheet", 'relative power');
                writetable(table_abs_power, name_xlsx, "Sheet", 'absolute power');
                writetable(table_psds, name_xlsx, "Sheet",'psds');
                writetable(table_freq, name_xlsx, "Sheet", 'frequencies');
                writetable(table_serr, name_xlsx, "Sheet", 'errors calculated');
            
                disp('Data saved');
                clear name_xlsx
            end
        end
        
    end
end