function [data,headers]=load_sto(inpath,infile);

% cd W:\OA_GaitRetraining\GastrocAvoidance\DATA
if nargin < 1
    [infile,inpath]=uigetfile('*.sto');
end

fid=fopen([inpath '\' infile],'r');
% disp(['Loading file...' infile] );
%read the file name line
line=fgetl(fid);
while isempty(strfind(line,'nRows'))
line=fgetl(fid);
end

% Read the number of data columns and rows
                    nr=sscanf(line(7:length(line)),'%f');
line=fgetl(fid);	nc=sscanf(line(10:length(line)),'%f');

line = 'a' ; 
while ~strcmp('endheader',line) ;
    line=fgetl(fid);
end
% Load the headers
headers=cell(nc,1);
line=fgetl(fid);
j=1;
jl=length(line);
for i=1:nc
    name=sscanf(line(j:jl),'%s',1);
    ii = findstr(line(j:jl), name);
    j=j+ii(1)+length(name);
    headers(i,1)=cellstr(name);
end
headers=headers';

% Now load the data
data=zeros(nr,nc);
i=0;
while ((feof(fid)==0)&(i<nr))
    i=i+1;
    line=fgetl(fid);
    data(i,:)=sscanf(line,'%f');
end
fclose(fid);
