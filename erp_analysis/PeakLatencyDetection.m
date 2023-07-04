% script to obtain the latency for the N1/P2 peaks complex at phrase onset for the 1000ms ERPs to be used
% later as a basis to decide which time window to use in analysis.

% checking the N1 peak latency

ALLERP = pop_geterpvalues( ALLERP, [80 200],  [1 2], [1:62 65] , 'Baseline', 'pre', 'erpsets', 1:29, 'Binlabel', 'on', 'FileFormat', 'long', 'Filename',...
 'C:\Users\Pell Lab\Documents\MATLAB\accent_perception\14.statistics\N1FinalPeakDetection.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peaklatbl',...
 'Neighborhood',  6, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',  2 );


% checking the P2 peak latency

ALLERP = pop_geterpvalues( ALLERP, [ 180 350],  [1 2], [1:62 65] , 'Baseline', 'pre','erpsets', 1:29, 'Binlabel', 'on', 'FileFormat', 'long', 'Filename',...
 'C:\Users\Pell Lab\Documents\MATLAB\accent_perception\14.statistics\P2FinalPeakDetection.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peaklatbl',...
 'Neighborhood',  6, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',  2 );


% checking the P3 peak latency

ALLERP = pop_geterpvalues( ALLERP, [ 300 500],  [1 2], [1:63] , 'Baseline', 'pre','erpsets', 1:29, 'Binlabel', 'on', 'FileFormat', 'long', 'Filename',...
 'C:\Users\Pell Lab\Documents\MATLAB\accent_perception\14.statistics\P3FinalPeakDetection.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peaklatbl',...
 'Neighborhood',  6, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',  2 );
