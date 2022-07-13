function f = plot_heatmap(data, figure_name, average, tapers, Fs, ...
    fpass, err, trialave, movingwin, save_path,log)

    params.tapers=tapers;
    params.Fs=Fs;
    params.fpass = fpass;
    params.err = err; % No err calculation
    params.trialave=trialave; % Average over trials
    movingwindow = movingwin; % movingwin = [winsize winstep]
    if not(average)
        for i = 1:length(data)
            seg_data = data{i};
            
            [S,t,f] = mtspecgramc(seg_data, movingwindow, params);
    
            plot_matrix(S,t,f,log);
    
            fig_name = strcat(save_path, figure_ame,'_', string(i), '.png');
            saveas(gcf,fig_name);
        end
    else
        [S,t,f] = mtspecgramc(data, movingwindow, params);
        plot_matrix(S,t,f,log);
        fig_name = strcat(save_path, figure_name,'_average', '.png');
        saveas(gcf,fig_name);
    end
    
end