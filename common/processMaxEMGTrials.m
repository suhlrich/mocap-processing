function [NORM] = processMaxEMGTrials(FILT,muscleNames,pathNames)
% This function processes max trials in the cell named pathNames. Filter
% parameters are stored in FILT. Max activations in Volts for the muscles defined in
% muscleName are stored in NORM.maxAct.[muscleName] 

for fnum = 1:length(pathNames)
   [header data] = ANCload(pathNames{fnum}) ; 
   
%    if fnum==1 % find muscle indicies if first trial
   mInds = zeros(1,length(muscleNames)) ;
    for m = 1:length(muscleNames)
        mInds(m) = strmatch(muscleNames{m},header.varnames) ;
    end
%    end
   analogSampleRate = header.samprates(mInds(1)) ;
   
   EMGraw = data(:,mInds) ; 
   gainArray = header.ranges(mInds) * .001 ; % in V
   EMGraw=(ones(size(EMGraw,1),1)*gainArray*2).*(EMGraw/65536) ; % Convert all data into volts
   
   % Bandpass Filter (4th order) - bandpass filter definition doubles the order.
   % Filtfilt also doubles the order. Thus prescribe n = 1, final order is
   % 4*n.
   [b,a] = butter(1,[FILT.EMGfiltFreq_BP(1)/(analogSampleRate/2) FILT.EMGfiltFreq_BP(2)/(analogSampleRate/2)]);
   EMGbp = filtfilt(b,a,EMGraw);
   % Rectify
   EMGabs = abs(EMGbp); 
   % Lowpass Filter (4th order). Filtfilt doubles filter order
   [B,A] = butter(2,FILT.EMGfiltFreq_LP/(analogSampleRate/2)) ; 
   EMGlp = filtfilt(B,A,EMGabs) ;

   maxVals(fnum,1:length(muscleNames)) = max(EMGlp) ;
end

NORM.muscleNames = muscleNames ;
NORM.maxAct = max(maxVals) ;

disp('Nice work! Max activation trials loaded, filtered, and peaks saved in NORM for future normalization.')
    