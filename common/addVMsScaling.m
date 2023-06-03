function addVMsScaling(filePath,fileName)

% This file adds adds virtual markers to a static trial to assist in scaling 
% according to Opensim Webinar by Jenny Yong and James Dunne in April 2017
% Written by Scott Uhlrich. 


% In opensim x forward, y up, z right

projDist = 0  ; % distance off floor for foot projections (mm)

nameChanges = {'r_shank(antsup)','r_shank_antsup';'L_shank(ant_sup)','L_shank_antsup'} ;

% basedir = 'C:\Users\suhlr_000\Dropbox\ME485\485Project\' ; % laptop
% basedir = 'C:\Users\scott.uhlrich\Documents\DelpResearch\HOBL\EMG_pilot\Edited\Files_W_HJCs\' ; % desktop
addpath(genpath('W:\OA_GaitRetraining\Matlab\common')) ;
%filePath = ['W:\OA_GaitRetraining\GastrocAvoidance\DATA\Subject10\Edited\Files_W_HJCs\'];
% filePath = ['W:\OA_GaitRetraining\OpenPoseTesting\DATA\Session20210422_0001\Edited\Files_W_HJCs\'];
% fileName = 'static4.trc' ;
% filePath = ['W:\OA_GaitRetraining\OpenSimAllSubjects\Subject_101\Gait\Week1\Files_W_HJCs\']; % 10/21/2020, testing S101, Wk1 (Janelle added)


newMarkerNames = {'midPSIS','midASIS','midHJC','midPelvis','R_KJC','L_KJC' ...
    'R_AJC','L_AJC','R_AJC_proj','R_5meta_proj','R_toe_proj', ...
    'L_AJC_proj','L_5meta_proj','L_toe_proj'} ;

[header data] = TRCload([filePath '/' fileName]) ;

markerIndicies = zeros(1,length(header.markername)) ;
for i = 1:length(header.markername)
    if i>2 
    markerIndicies(i) = ~isempty(header.markername{i}) ;
    end
end
originalMarkerNames = header.markername(find(markerIndicies))' ;
markerNames = [originalMarkerNames; newMarkerNames(:)] ;

for i = 1:size(nameChanges,1)
    tempInd = strmatch(nameChanges(i,1),markerNames,'exact') ;
    markerNames(tempInd) = nameChanges(i,2) ;
end

% The '(' in the '(antsup)' marker names are seen as functions. have to
% change to r_shank_antsup in trc file
matlabMarkerNames = {originalMarkerNames{1} 'r_shank_antsup' originalMarkerNames{3:7} ...
                     'L_shank_antsup' , originalMarkerNames{9:end} };
                 

                 
% markerIndicies
for i = 1:length(originalMarkerNames) 
    eval(['inds.' matlabMarkerNames{i} '= find(strcmp(header.markername,''' originalMarkerNames{i} ''')) ;'])
end

nRows = size(data,1) ;
newData = zeros(nRows,3*length(newMarkerNames)) ;
%%%%%%% Start making new markers %%%%%%%%
% hard coded marker names 
newData(:,1:3) = squeeze(mean(reshape([data(:,inds.r.PSIS:inds.r.PSIS+2)...
                 ,data(:,inds.L.PSIS:inds.L.PSIS+2)],nRows,3,2),3)) ; % midPSIS
newData(:,4:6) = squeeze(mean(reshape([data(:,inds.r.ASIS:inds.r.ASIS+2)...
                 ,data(:,inds.L.ASIS:inds.L.ASIS+2)],nRows,3,2),3)) ; % midASIS
newData(:,7:9) = squeeze(mean(reshape([data(:,inds.R_HJC:inds.R_HJC+2)...
                 ,data(:,inds.L_HJC:inds.L_HJC+2)],nRows,3,2),3)) ; % midHJC
newData(:,10:12) = squeeze(mean(reshape([newData(:,1:3)...
                 ,newData(:,4:6)],nRows,3,2),3)) ; % midPelvis
newData(:,13:15) = squeeze(mean(reshape([data(:,inds.r_knee:inds.r_knee+2)...
                 ,data(:,inds.r_mknee:inds.r_mknee+2)],nRows,3,2),3)) ; % R_KJC
newData(:,16:18) = squeeze(mean(reshape([data(:,inds.L_knee:inds.L_knee+2)...
                 ,data(:,inds.L_mknee:inds.L_mknee+2)],nRows,3,2),3)) ; % L_KJC
newData(:,19:21) = squeeze(mean(reshape([data(:,inds.r_ankle:inds.r_ankle+2)...
                 ,data(:,inds.r_mankle:inds.r_mankle+2)],nRows,3,2),3)) ; % R_AJC
newData(:,22:24) = squeeze(mean(reshape([data(:,inds.L_ankle:inds.L_ankle+2)...
                 ,data(:,inds.L_mankle:inds.L_mankle+2)],nRows,3,2),3)) ; % L_AJC
newData(:,25:27) = [newData(:,19) projDist*ones(nRows,1) newData(:,21)]  ; % R_AJC_proj
newData(:,28:30) = [data(:,inds.r_5meta) projDist*ones(nRows,1) data(:,inds.r_5meta+2)]  ; % R_5meta_proj
newData(:,31:33) = [data(:,inds.r_toe) projDist*ones(nRows,1) data(:,inds.r_toe+2)]  ; % R_toe_proj
newData(:,34:36) = [newData(:,22) projDist*ones(nRows,1) newData(:,24)]  ; % L_AJC_proj
newData(:,37:39) = [data(:,inds.L_5meta) projDist*ones(nRows,1) data(:,inds.L_5meta+2)]  ; % L_5meta_proj
newData(:,40:42) = [data(:,inds.L_toe) projDist*ones(nRows,1) data(:,inds.L_toe+2)]  ; % L_toe_proj

             
combinedData = [data(:,3:end) newData(:,:)] ;
             
writeTRCFile(data(:,strmatch('Time ',header.markername)),combinedData,markerNames,filePath,[fileName(1:end-4) '_VM'])
