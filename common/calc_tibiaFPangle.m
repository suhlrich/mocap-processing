function [perStep_u, meanPerStep, trace_u, traces] = calc_tibiaFPangle(markers,leg,recframes,goodtrials)
% This calculates frontal plane projection of tibia angle from maleolus and
% femoral epicondyle markers. An angle medial to straight up is positive.
% markers is an nsamples x 12 markers matrix with X,Y,Z coordinates of
% r_knee, r_ankle, L_knee, L_ankle
% traces is a numsteps x 101 matrix with tibia angle over stance
% meanPerStep  is numsteps x 1 with average tibia angle
% trace_u is 1 x 101 with average tibia angle over stance
% perStep_u is scalar (mean(mean(traces))

if leg == 'r'
    markers = markers(:,1:6) ;
    legSign = 1 ;
else % left leg
    markers = markers(:,7:12) ;
    legSign = -1 ;
end

nSteps = find(recframes(:,1),1,'last') ;
tibVec = zeros(length(markers),3) ;
tibVec(:,2:3) = markers(:,2:3) - markers(:,5:6) ;



tibAng = zeros(length(goodtrials),101) ;
tempVec = zeros(1,200) ;
k = 1 ;
for i = 1:nSteps
    if ismember(i,goodtrials)
        nFrames = find(recframes(i,:),1,'last') ;
        for j = 1:nFrames
            frame = recframes(i,j) ;
            tempVec(j) = acosd(tibVec(frame,3)/norm(tibVec(frame,:))) *legSign * sign(tibVec(frame,2));
        end
        tibAng(k,1:101) = interp101(tempVec) ;
        tempVec = zeros(1,200) ;
        k = k+1 ;
    end
end

traces = tibAng ;
trace_u = mean(traces) ;
meanPerStep = mean(traces,2) ;
perStep_u = mean(meanPerStep) ;
end