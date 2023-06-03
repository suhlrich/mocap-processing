function [strideLength strideLength_u] =  calc_strideLengthTM(markers, leg, recframes,goodtrials,TMspeed,samprate)
% This function takes in XYZ marker data from the r_heel (col 1:3), L_heel (col 4:6) and 
% calculates stride length based on heel marker data and treadmill belt
% speed in m/s. Finds difference in heel positions, then adds to time in
% between heel strikes times belt speed.

if leg == 'r'
    heel = markers(:,1:3) ;
else
    heel = markers(:,4:6) ;
end

strideLength = zeros(1,length(goodtrials)) ;

j = 1 ;
nSteps = find(recframes(:,1),1,'last') ;
for i = 1:size(recframes,1)
    if ismember(i,goodtrials)
        dHeel = diff(heel(recframes(i:i+1,1),1)) ;
        dBelt = (diff(recframes(i:i+1,1))/samprate) * TMspeed ;
        
        strideLength(j) = dHeel+dBelt ;
        j = j+1 ;
    end
end

strideLength_u = mean(strideLength) ;


end

