function [mkrData] = findMarkerData(desiredMkrNames,header,data)

mkrData = zeros(size(data,1),length(desiredMkrNames)*3) ;

for i = 1:length(desiredMkrNames)
    mkrInd = strmatch(desiredMkrNames{i},header.markername) ;
    mkrData(:,(i-1)*3+1:i*3) = data(:,mkrInd:mkrInd+2) ;    
end
    