addpath('W:\OA_GaitRetraining\Matlab\common')

k = size(BiomechParamMat,2);
valuesMatrix = [];
KAMvals=[];
for j=1:k
    KAMvals = [KAMvals BiomechParamMat(j).KAM'];
%    vals2 = rand(10,3) ;
end
valuesMatrix(:,1,:) = KAMvals ;
% valuesMatrix(:,2,:) = vals2 ;
GT = 1:size(valuesMatrix,3) ;
badTrials = [] ;
numtrials = size(valuesMatrix,3) ;
plotTitles = {'KAM'} ;
[visuallyGoodTrials] = visualPlotEditing(valuesMatrix,GT,badTrials,numtrials,plotTitles);