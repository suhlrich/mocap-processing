function wSpeed = calcWalkingSpeedFromMarkers(wSpeedMarkers,recframes,samprate) ;

dt = 1/samprate ;
wSpeed_allSteps = zeros(max(find(recframes(:,1))),1) ;

yDiff = diff(wSpeedMarkers(:,1,:))/dt ;

for i = 15:length(wSpeed_allSteps)-15
    maxRF = max(recframes(i,:)) ;
    minRF = min(recframes(i,1:find(recframes(i,:),1,'last'))) ;
    start = ceil(.3*(maxRF-minRF)+minRF) ;
    finish = ceil(.5*(maxRF-minRF)+minRF) ;
    wSpeed_allSteps(i) = -mean(yDiff(start:finish)) ;
end

wSpeed = nanmean(wSpeed_allSteps(find(wSpeed_allSteps))) ;
