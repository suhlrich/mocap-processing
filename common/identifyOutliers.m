function outlierTrials = identifyOutliers(inMatrix,numSDs,nTrials)
% This function identifies a timeseries that is numSDs above the median of
% all of the traces. Input is a matrix of nSamples x nTrials - or the other
% way around with nTrials specified. outlierTrials are the trial numbers to
% get rid of.


%make sure nTrials is nRows
if nTrials ~= size(inMatrix,1) ;
    inMatrix = inMatrix' ;
end

medianTrace = median(inMatrix) ;
inMatrixSorted = sort(inMatrix) ;
sdVec = std(inMatrixSorted(4:end-3,:)) ;

aboveRange = sum(double(inMatrix>repmat(medianTrace+numSDs*sdVec,nTrials,1)),2) ;
belowRange = sum(double(inMatrix<repmat(medianTrace-numSDs*sdVec,nTrials,1)),2) ;
outlierTrials = unique([find(aboveRange>2)', find(belowRange>2)']) ;