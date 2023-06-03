function runHJC(fileNames,fileDirectory,openSimRot)
% filenames = {'eval_pre','eval_post'} ; 
% subjectdir = 'W:\OA_GaitRetraining\DATA\Subject155\Gait\Week39' ;
% openSimRot = 1 if rotate for opensim

addpath(genpath('W:/OA_GaitRetraining/Matlab/common/')) ;

HJCinputNames.basepath = [fileDirectory '\Edited\'] ;
HJCinputNames.static = 'static1.trc' ;
HJCinputNames.RHJC = 'RHJC1.trc' ;
HJCinputNames.LHJC = 'LHJC1.trc' ;
HJCinputNames.trials = cellfun(@(x) [x '.trc'],fileNames,'UniformOutput',false) ;
HJCinputNames.trials = horzcat(HJCinputNames.trials,'static1.trc') ;
findHJC_Dynamic_Regression(HJCinputNames,HJCinputNames.basepath,openSimRot); % No rotation
