function [] = writeOpenSimControlsSto(ExcitationMatrix,time,muscleNames,outFile) 

% This function takes input control matrix, time vector, and muscle name
% cell to write a control storage file (*.sto)
% for Opensim Python script to turn into control file (*.xml)
% Written by Scott Uhlrich and Cara Nunez 5/24/2017

% ExcitationMatrix is an nSample x nMuscle matrix
% of 0-1 excitations
% muscle names is a cell
% time is a vector
% outFile is a string for the output file name

%%%%%%%%%%%%%%%%%% for testing as a script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% outFile = 'C:\Users\scott.uhlrich\Dropbox\ME485\485Project\Controls\TestControls.sto' ;
% muscleNames = {'oneMuscle','twoMuscle','blueMuscle','redMuscle'} ;
% ExcitationMatrix = [1 2 3 4; 2 3 4 5]' ;
% time = [.2 .4] ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if size(ExcitationMatrix,1) == length(muscleNames) ;
    warning('Your Excitation Matrix is likely flipped, should be nSamples x nMuscles')
end

fid = fopen(outFile,'w') ;
nRows = length(time) ;
nColumns = length(muscleNames) + 1 ;

fprintf(fid,'controls\nversion=1\nnRows=%i\nnColumns=%i\ninDegrees=no\nendheader\n',nRows,nColumns) ;

% write column names
fprintf(fid,'time    ') ;
for i = 1:nColumns-1
    fprintf(fid,[muscleNames{i} '     ']) ;
end

for i = 1:nRows
    fprintf(fid,'\n') ;
    fprintf(fid,'%.4f     ',time(i)) ;
    for j = 2:nColumns
        fprintf(fid,'%.4f     ',ExcitationMatrix(i,j-1)) ;
    end
end
fclose(fid) ;