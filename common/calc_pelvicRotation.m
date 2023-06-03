function [perStep_u, meanPerStep, trace_u, traces] = calc_pelvicRotation(markers,leg,recframes,goodtrials)
% This calculates transverse plane projection of ASIS line from 
% markers is an nsamples x 6 markers matrix with X,Y,Z coordinates of
% r_ASIS, L_ASIS. Then computes lab-frame pelvic rotation angle (physical
% angle) with stance-limb forward as positive.
% traces is a numsteps x 101 matrix with pelvic list over stance
% meanPerStep  is numsteps x 1 with average pelvic list
% trace_u is 1 x 101 with average pelvic list angle over stance
% perStep_u is scalar (mean(mean(traces))


if leg == 'r'
    stanceMarkers = markers(:,1:2) ;
    swingMarkers = markers(:,4:5) ;
    yVec = [0 -1 0] ;
else % left leg
    stanceMarkers = markers(:,4:5) ;
    swingMarkers = markers(:,1:2) ;
    yVec = [0,1,0] ;
end

nSteps = find(recframes(:,1),1,'last') ;
pelvVec = zeros(length(markers),3) ;
pelvVec(:,1:2) = stanceMarkers-swingMarkers ; % stance ASIS to swing ASIS, z will be negative with pevlic drop



pelvAng = zeros(length(goodtrials),101) ;
tempVec = zeros(1,200) ;
k = 1 ;
for i = 1:nSteps
    if ismember(i,goodtrials)
        nFrames = find(recframes(i,:),1,'last') ;
        for j = 1:nFrames
            frame = recframes(i,j) ;
            tempVec(j) = acosd(dot(pelvVec(frame,:),yVec)/norm(pelvVec(frame,:))) * sign(pelvVec(frame,1)) ;
            if i==1
                figure(2)
                hold on
                plot(pelvVec(frame,1),pelvVec(frame,2)) ;
            end
        end
        pelvAng(k,1:101) = interp101(tempVec) ;
        tempVec = zeros(1,200) ;
        k = k+1 ;
    end
end

traces = pelvAng ;
trace_u = mean(traces) ;
meanPerStep = mean(traces,2) ;
perStep_u = mean(meanPerStep) ;
end