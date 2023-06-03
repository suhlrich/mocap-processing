function [] = skyRename(customFolderName) 
% customFolderName = 'W:\OA_GaitRetraining\DATA\RecruitedSubjects\SubjectR974\Gait\Week1\Edited\' ;
% customFolderName = 'C:\Users\suhlr_000\Dropbox\ME485\485Project\Scott5_3_17\Edited' ;
% customFolderName = 'W:\OA_GaitRetraining\forScott\JS_day3\Edited\' ;

% Delete anb files
badfiles = dir([customFolderName '\Trimmed*.anb']) ;
try
for j= 1:length(badfiles)
    delete([customFolderName '\' badfiles(j).name])
end
end

% Rename .anc and .trc files
files = dir([customFolderName '\Trimmed*']) ;
for j = 1:length(files)
    fname = [customFolderName '\' files(j).name] ;
    copyfile(fname,strrep(fname,'Trimmed_','')) ;
    delete(fname)
end