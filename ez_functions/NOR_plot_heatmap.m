function f = NOR_plot_heatmap(data_path, filename, tapers, Fs, fpass, err, trialave, movingwin, save_path)
    load_arg = strcat(data_path, filename);

    load(load_arg,'seg_data_both');
    params.tapers=tapers;
    params.Fs=Fs;
    params.fpass = fpass;
    params.err = err; % No err calculation
    params.trialave=trialave; % Average over trials
    movingwindow = movingwin; % movingwin = [winsize winstep]
    for i = 1:length(seg_data_both)
        seg_data = seg_data_both{i};
        
        [S,t,f] = mtspecgramc(seg_data, movingwindow, params);

        plot_matrix(S,t,f);

        fig_name = strcat(save_path, filename,'_', string(i), '.png');
        saveas(gcf,fig_name)
    end
    
end