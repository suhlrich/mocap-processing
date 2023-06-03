function [TH_Ratio, TOpercent, HOpercent,footAng] = calc_HeelToeTime(markers,leg,recframes,goodtrials)
% This calculates percent of time spent on the heel, on the toe, and the
% ratio between the two.
% markers is an nsamples x 12 markers matrix with X,Y,Z coordinates of
% r_heel, r_toe, L_heel, L_toe
% TH_Ratio is a 1 x numsteps vector of the ratio of time spent on heel over
% time spend on toe
% TOpercent is a 1 x numsteps vector of the percentage of step before toe
% hits ground
% HOpercent is a 1 x numsteps vector of the percentage of step after heel
% lifts off ground 
% footAng is the trace of the foot angle with midstance foot angle
% subtracted out

if leg == 'r'
    markers = markers(:,1:6) ;
    legSign = 1 ;
else % left leg
    markers = markers(:,7:12) ;
    legSign = -1 ;
end

footVec = markers(:,4:6) - markers(:,1:3);
footVec_proj = zeros(size(footVec)) ; footVec_proj(:,1:2) = footVec(:,1:2) ; % remove Z component
nSteps = find(recframes(:,1),1,'last') ;




footAng = zeros(length(goodtrials),101) ;
TOpercent = zeros(1,length(goodtrials)) ;
HOpercent = zeros(1,length(goodtrials)) ;
tempVec = zeros(1,200) ;
k = 1 ;
for i = 1:nSteps
    if ismember(i,goodtrials)
        nFrames = find(recframes(i,:),1,'last') ;
        for j = 1:nFrames
            frame = recframes(i,j) ;
            tempVec(j) = acosd(dot(footVec(frame,:),footVec_proj(frame,:))/(norm(footVec(frame,:))*norm(footVec_proj(frame,:)))) * sign(footVec(frame,3)) ;
        end
        fAngle = interp101(tempVec) ;
        footAng(k,1:101) = fAngle ;
        tempVec = zeros(1,200) ;
        TOpercent(k) = find(fAngle < fAngle(50) + 5, 1);
        HOpercent(k) = 101 - find(fAngle < (fAngle(50) - 5), 1);
        k = k+1 ;
    end
end

TH_Ratio = TOpercent./HOpercent ;
end