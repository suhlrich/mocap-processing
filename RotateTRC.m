%% This script Rotates TRC files to Opensim land in batch
clear all;
close all;
clc;

[files, inpath]=uigetfile('*.trc','Select input file','multiselect','on');
files=cellstr(files);
[a b] = size(files);

%should be 46 markers 
%pos should be (#x138) not 168 or 156
for index=1:b;
    infile=char(files(:,index));
    [pos,time,f,n,nmrk,mrk_names,file,inpath]=load_trc(infile,inpath);

% rotate the marker data into an OpenSim model coordinate system
R = [1 0 0; 
    0 0 -1; 
    0 1 0];

%rotate x forward
R = R* [0 0 -1;
        0 1 0;
        1 0 0] ;

mrkdata = pos;
for i=1:3:size(mrkdata,2)-2;
    mrkdata(:,i:i+2)=mrkdata(:,i:i+2)*R;
end
S= strcat('rotated_',infile);
S = S(1:end-4);

done = writeTRCFile(time,mrkdata,mrk_names,inpath,S);
if done==1
    display(['File ' infile ' written with OpenSimRotation']);
end
end