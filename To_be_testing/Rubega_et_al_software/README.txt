If your data are in the required .mat format:
- to run the software, open ‘main_script.m’ in MATLAB and press the bottom ‘Run’


Otherwise:

- arrange your data in a .txt file in columns (the first one must contain the time vector and the others the amplitudes of the recordings)

and run 'data_from_txt_to_mat.m’ to convert your data in .mat format



 The only files to run are:

'data_from_txt_to_mat.m’ -->  	Thanks to this script it's possible to convert file.txt (containing data) into files.mat.
				
				The file.txt MUST be organised in columns, in which the first one contains the time vector and the others the amplitudes of the recordings.
				The file.mat will contain a matrix RAT (number of samples x number of
				sweeps), a vector new_time (number of samples x 1) and a struct
				parameters (parameters.dT=sampling step; parameters.Fs=sampling frequency; parameters.Ns=number of samples for each sweep)


'main_script.m'   --> 	Thanks to this script, it's possible to compute and to visualize the smoothing of the signal, 
			its first/second time-derivative,
			and the other features of interest (maximum, onset, inflection point, latency).
			All results will be saved in an excel file (each sheet will contain the results relative to a particular depth).


*If you want to test the program, a set of real data named 'test_data.mat' is provided (containing 2 examples of LFP signals after whisker stimulation).


*'smoothing_first_derivative.m', 'smoothing_second_derivative.m', 'find_negativepeak_onset_max.m', 'find_negativepeak.m'
 are functions to guarantee the correct running of 'main_script.m'. Please, be sure that all these scripts are in the 
 same folder!




