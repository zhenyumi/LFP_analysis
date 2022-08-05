function [data_c,freq_c] = cut_by_freq(data, freqs, freq_band, approximate)
% Input:
%   data: The data want to cut (according to frequency)
%   freqs: The *frequency* that correspond to *data*
%   freq_band: The frequency band required
%       Example: [lower_limit upper_limit]
%   approximate: If this variable is set true, will find the closest index
%       of given lower and upper limit instead of using the absolute value
%       default: false
% Output:
%   data_c: The data cutted
%   freq_c: The frequency cutted corresponding to *data_c*

    if(~exist('approximate','var'))
        approximate = false;
    end
    lower_limit = freq_band(1);
    upper_limit = freq_band(2);
    cutted_data = [];
    cutted_frequency = [];
    if approximate
        [m,lower_index] = min(abs(freqs-lower_limit));
        [m,upper_index] = min(abs(freqs-upper_limit));
        cutted_frequency = freqs(lower_index:upper_index);
        cutted_data = data(lower_index:upper_index);
        % fprintf("Cutted from %1$0.1f to %2$0.1f Hz. \n",freqs(lower_index),freqs(upper_index));
    else
        for i = 1:length(data)
            item = data(i);
            if freqs(i) >= lower_limit && freqs(i) <= upper_limit
                cutted_data = [cutted_data;item];
                cutted_frequency = [cutted_frequency;freqs(i)];
            end
        end
    end

    data_c = cutted_data;
    freq_c = cutted_frequency;
end