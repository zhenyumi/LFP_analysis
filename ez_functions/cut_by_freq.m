function [data_c,freq_c] = cut_by_freq(data, freqs, freq_band)
% Input:
%   data: The data want to cut (according to frequency)
%   freqs: The *frequency* that correspond to *data*
%   freq_band: The frequency band required
%       Example: [lower_limit upper_limit]
% Output:
%   data_c: The data cutted
%   freq_c: The frequency cutted corresponding to *data_c*

    lower_limit = freq_band(1);
    upper_limit = freq_band(2);
    cutted_data = [];
    cutted_frequency = [];

    for i = 1:length(data)
        item = data(i);
        if freqs(i) >= lower_limit && freqs(i) <= upper_limit
            cutted_data = [cutted_data;item];
            cutted_frequency = [cutted_frequency;freqs(i)];
        end
    end

    data_c = cutted_data;
    freq_c = cutted_frequency;
end