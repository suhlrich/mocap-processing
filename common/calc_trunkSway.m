function [max_u,max_sd,max_vec,trace_u,trace_sd,traces] = calc_trunkSway(C7,PSIS_r,PSIS_l,leg,recframes,goodtrials,stanceTimes)
% Computes trunk sway from Shull 2013 using x,y,z marker positions of C7,
% positive values are leaning over the ipsilateral leg
% PSIS, in nFrames x 3 matrix. Leg is either 'r', or 'l'; 
% only need stanceTimes i

n = size(C7,1) ;
angleVec = zeros(n,1) ;

vecTemp = C7 - 0.5*(PSIS_r+PSIS_l) ;
vecTemp(:,1) = 0 ;

for i = 1:n
    vecNorm(i,:) = vecTemp(i,:)/norm(vecTemp(i,:)) ;
    angleVec(i) = acosd(vecNorm(i,3)) * sign(vecNorm(i,2)) ; % dot(vec,z)
end
    
if leg == 'r' ; angleVec = -1*angleVec ; end

lastRecFrame = find(recframes(:,1),1,'last') ;
traces = zeros(length(goodtrials),101) ;
allVals = zeros(length(goodtrials),1); 

j = 1 ;
for i=1:lastRecFrame
    if sum(find(goodtrials==i))
        frames = recframes(i,1):max(recframes(i,:)) ;
        traces(j,:) = interp101(angleVec(frames)') ;
        j = j+1 ;
    end
end

max_vec = zeros(length(goodtrials),1) ;
trace_u = mean(traces,1) ;
trace_sd = std(traces,0,1) ;
if ~exist('stanceTimes') ; % if didn't give specific times during gait cycle to pull values from
    max_vec = max(traces,[],2) ;
else
    for i = 1:length(stanceTimes)
        max_vec(i) = traces(i,stanceTimes(i)) ;  % should this be max? (SDU 1/2/19) - oh well i don't use it that way
    end
end
max_u = mean(max_vec) ; 
max_sd = std(max_vec) ;

