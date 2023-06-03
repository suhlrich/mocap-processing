function [FPAout FPAvec] = calc_FPAfromMarkers(FPAmarkers,stepFrames,stancePercentages,leg,FPAsubtraction,directionMultiplier)
% markers = nsamples x 4 matrix [calc_x calc_y toe_x toe_y] ;
% stepframes = frames during a step (nsteps x ~nsamples) with padding 0s
% leg = 'r' 'R' 'l' or 'L'
% stancePercentages = percentage of stance to calculate FPA (15-40 is what
% RT program does)
% FPAsubtraction: subtract baseline and offset? - shouldn't have to do this
% directionMultiplier positive when walking in positive x direction,
% negative otherwise

if leg == 'l' || leg == 'L'
    FPAmult = 1 ;
elseif leg == 'r' || leg == 'R'
    FPAmult = -1 ;
else
    disp('you put in the wrong argument for leg')
end

if nargin <5
    FPAsubtraction = 0 ;
end
if nargin <6
    directionMultiplier = 1 ;
end

stancePerc1 = stancePercentages(1)/100 ;
stancePerc2 = stancePercentages(2)/100 ;


calc_x = FPAmarkers(:,1) ;
calc_y = FPAmarkers(:,2) ;
toe_x = FPAmarkers(:,3) ;
toe_y = FPAmarkers(:,4) ;

FPAvec = zeros(1,length(calc_x)) ;

for i = 1:length(calc_x)
    footvec = [toe_x(i)-calc_x(i) toe_y(i)-calc_y(i)] ;
    FPAvec(i) = acosd(directionMultiplier*footvec(1)/norm(footvec)) * directionMultiplier * FPAmult * sign(-calc_y(i)+toe_y(i)) - FPAsubtraction ;
end


FPAout = zeros(length(find(stepFrames(:,1))),1) ;
for i = 1:size(stepFrames,1) ;
    if stepFrames(i,1)~=0
        frames = stepFrames(i,find(stepFrames(i,:))) ;
        ind1 = frames(1)+round(stancePerc1*range(frames)) ;
        ind2 = frames(1)+round(stancePerc2*range(frames)) ;
        FPAout(i) = mean(FPAvec(ind1:ind2)) ; 
    end
end
