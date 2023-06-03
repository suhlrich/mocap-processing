function [KIN] = loadKinetics(subjects)


disp('Loading Kinetics') ;
for sub = 1:length(subjects) ;
    load(['W:\OA_GaitRetraining\DATA\Subject' num2str(subjects(sub)) '\Gait\ALLWK.mat'])
    subStr = ['S',num2str(subjects(sub))] ;
    KIN.(subStr) = ALLWK ;
end



