function EMGout = postprocessEMGwholetrial(EMGraw,FILT,analogSampleRate,downsampleRate)
% data is filtered analog
% FILT has filtering frequencies in it
% nsamples x nmuscles
% downsampleRate is marker sample rate if you want to downsample to it.

nmusc = size(EMGraw,2) ;

% Bandpass Filter (4th order) - bandpass filter definition doubles the order.
    % Filtfilt also doubles the order. Thus prescribe n = 1, final order is
    % 4*n.
    [b,a] = butter(1,[FILT.EMGfiltFreq_BP(1)/(analogSampleRate/2) FILT.EMGfiltFreq_BP(2)/(analogSampleRate/2)]);
    EMGbp = filtfilt(b,a,EMGraw);

    % Rectify
    EMGabs = abs(EMGbp); 

    % Lowpass Filter (4th order). filtfilt doubles filter order
    [B,A] = butter(2,FILT.EMGfiltFreq_LP/(analogSampleRate/2)) ; 
    EMGlp = filtfilt(B,A,EMGabs) ;
    
    if ~exist('downsampleRate') ; downsampleRate = 1 ; end
    EMGout = EMGlp(1:downsampleRate:end,:) ;
