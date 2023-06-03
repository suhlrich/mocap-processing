function [traces u stdev inds_coords] = postprocessIK_ID(data,header,vars2usebase,varname2append,stepInds,goodtrials,normFactor,filtFreq) ;

if ~exist('normFactor') ; normFactor = 1 ; end ;

vars2use = cellfun(@(c)[c varname2append],vars2usebase,'uni',false) ;
for i = 1:length(vars2use)
    inds_data(i) = strmatch(vars2use{i},header,'exact') ;
    inds_coords.(vars2usebase{i}) = i ;
end
data2use = data(:,inds_data) ;
data2use = data2use*normFactor ;

if exist('filtFreq') ; 
    % find sample frequency
    idx_time = strmatch('time',header,'exact') ;
    timeVec = data(:,idx_time) ;
    sampFreq = (timeVec(2)-timeVec(1))^-1 ;

    [B,A] = butter(3,filtFreq/(0.5*sampFreq)) ; % 6th order butter - this is what opensim is doing
    data2use = filtfilt(B,A,data2use) ;
end ;

if ~exist('goodtrials')
    goodtrials = 1:size(stepInds,1) ;
end

nsteps = size(stepInds,1) ;
IK_steps = zeros(length(goodtrials),101,length(vars2use)) ;
for i = 1:length(goodtrials)
    gt = goodtrials(i) ;
    IK_steps(i,1:101,:) = interpTrace(data2use(stepInds(gt,1):stepInds(gt,2),:)')';
end

traces = permute(IK_steps,[1,3,2]) ; %nsteps x ncoords x 101
u = mean(traces,1) ;
stdev = std(traces,0,1) ;