function EMGout = postprocessEMG(EMGraw,FILT,analogSampleRate,markerSampleRate,stepInds,timeDelay)
% data is filtered analog
% EMGraw is nSamples x nMuscles
% FILT has filtering frequencies in it for bandpass and lowpass filters
% stepInds has HS and TO indicies
% nsamples x nmuscles x nsteps

if ~exist('timeDelay')
    timeDelay = 0 ;
end

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
    EMG_downsamp = EMGlp(1:analogSampleRate/markerSampleRate:end,:) ;
    
    time = 0:1/markerSampleRate:size(EMG_downsamp,1)/markerSampleRate ;
    
    % Segmenting into steps based on stepInds
    [~,ind] = min(abs(time-timeDelay)) ;% index of starting number
    EMG_downsamp_shift = [repmat(EMG_downsamp(1,:),ind-1,1); EMG_downsamp(1:end-ind+1,:)] ;
    
    nsteps = size(stepInds,1) ;
    EMG_steps = zeros(nsteps,101,nmusc) ;
    for i = 1:nsteps
        EMG_steps(i,1:101,:) = interpTrace(EMG_downsamp_shift(stepInds(i,1):stepInds(i,2),:)')';
    end
    
    EMGout = permute(EMG_steps,[2,3,1]) ; %nsamples x nmuscles x nsteps
