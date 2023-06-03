function [anklePSIS_interp_traces, anklePSIS_interp_u, anklePSIS_peak, anklePSIS_peak_u] = ... 
    calc_anklePSIS_APdist(markers, leg, recframes,goodtrials)
% This function takes in XYZ marker data from RPSIS, LPSIS, and both AJCs
% Just calculates the fore-aft position of AJC in front of mid-PSIS.

rPSIS = markers(:,1:3) ;
lPSIS = markers(:,4:6) ;
rAJC = markers(:,7:9) ;
lAJC = markers(:,10:12) ;

if leg == 'r' || leg == 'R'
    AJC = rAJC ;
else 
    AJC = lAJC ;
end

sacrum = (rPSIS+lPSIS)/2 ;

j = 1 ;
if exist('recframes')
    nSteps = find(recframes(:,1),1,'last') ;
    for i = 1:size(recframes,1)
        if ismember(i,goodtrials)
            nFrames = find(recframes(i,:),1,'last') ;
            frameRg = recframes(i,1:nFrames) ;
            anklePSIS_interp_traces(j,:) = interp101([AJC(frameRg,1)-sacrum(frameRg,1)]') ;
            anklePSIS_peak(j) = max(anklePSIS_interp_traces(j,:)) ;
            j = j+1 ;
        end
    end
    anklePSIS_interp_u = mean(anklePSIS_interp_traces) ;
    anklePSIS_peak_u = mean(anklePSIS_peak) ;
else
    anklePSIS_interp_traces = AJC(:,2)-sacrum(:,1) ;
    anklePSIS_interp_u = nan ;
    anklePSIS_peak = nan ;
    anklePSIS_peak_u = nan ;
end

end
