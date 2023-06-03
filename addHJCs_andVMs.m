clc; close all; format compact; clear
repoDir = [pwd,'\']
addpath([repoDir, 'common']);

% % % User defined vars
dataFolder = [repoDir 'Data\overgroundForces'] ;

% For HJCs
TNames.basepath = dataFolder ;
TNames.static = 'static1.trc' ;
TNames.RHJC = 'RHJC1.trc' ;
TNames.LHJC = 'LHJC1.trc' ;
% % % %


% HJCs - get files
fNames = dir([dataFolder '*.trc']) ;
trialNames = {fNames(:).name} ;
keepInds = find(contains(trialNames,'extrinsic')==0) ;
trialNames = trialNames(keepInds)

TNames.trials = trialNames ;

% Find HJCs
findHJC_Dynamic_Regression(TNames,dataFolder,true);

% Add virtual markers 
addVMsScaling([dataFolder '\Files_W_HJCs'],TNames.static)
