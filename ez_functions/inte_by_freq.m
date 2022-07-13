function result = inte_by_freq(data, freq, freq_band, type)
% Input:
%   data: The data want to cut (according to frequency)
%   freqs: The *frequency* that correspond to *data*
%   freq_band: The frequency band required
%       Example: [lower_limit upper_limit]
%   type: The integration method
%       simps: Using the Complex Sipmson's rule (simps.m needed)
%       trapz: The Trapezoidal numerical integration (built-in function)
% Outpus:
%   result: The integration result

    if (~exist('type','var'))
        type = 'trapz';
    end

    [data_c, freq_c] = cut_by_freq(data, freq, freq_band);

    if strcmp(type, 'simps')
        % result = simps(x, y);
        result = simps(ferq_c, data_c);
    elseif strcmp(type, 'trapz')
        % result = trapz(x, y);
        result = trapz(freq_c, data_c);
    end

end