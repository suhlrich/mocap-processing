function [pos,time,f,n,nmrk,mrk_names,file,inpath]=load_trc(infile,inpath);
%   [pos,time,f,n,nmrk,mrk_names]=load_trc(infile)
%   LOAD_TRC is used to open a data file from Motion Analysis Realtime
%   output (*.trc).
%   
%   Inputs
%       infile - trc file to be loaded
%                If infile is unspecified, the user is prompted to select the input file
%       inpath - directory of location where data file is located
%               when no path is specified, it defaults to current directory
%
%   Outputs:
%       pos     contains - the meaured marker positions in order of the markers
%               that is columns 1-3 are the x,y,z components of marker 1
%                       columns 4-6 are the x,y,z components of marker 2
%                          ....
%       time - column vector of time
%       f - sample frequency
%       n - number of data frames
%       nmrk - number of markers
%       mrk_names - marker names


n = nargin;
if (n==0)
    [infile, inpath]=uigetfile('*.trc','Select input file');
    if infile==0;
        f='';
        n='';
        nmrk='';
        mrk_names='';
        data=[];
        return;
    end
    fid=fopen([inpath infile],'r');
    file = infile(1:length(infile)-4);
elseif (n==1)
    file = infile(1:length(infile)-4);
    fid=fopen(infile,'r');
else (n==1)
    file = infile(1:length(infile)-4);
    fid=fopen([inpath infile],'r');
end

if (fid==-1)
    disp('File not found');
    f='';
    n='';
    nmrk='';
    mrk_names='';
    data=[];
    return;
end

disp(['Loading file...' infile] );

%disregard header info
for h=1:2
    hdr=fgetl(fid);
end
file_info=fscanf(fid,'%f');
f=file_info(1);
nmrk=file_info(4);
hdr=fscanf(fid,'%s',4);
line=fgetl(fid);
line=fgetl(fid);
j=1;
jl=length(line);
for i=1:(nmrk+2)
    name=sscanf(line(j:jl),'%s',1);
    ii=findstr(line(j:jl),name);
    j=j+ii(1)+length(name);
    if i>2
    mrk_names(i-2,1)=cellstr(name);
    end
end

%mrk_names=fscanf(fid,'%s',nmrk+2);
for h=1:2
    hdr=fgetl(fid);
end

line=[];
data=[];
while(length(data)<((nmrk*3)+2))
    line=fgetl(fid);
    data=sscanf(line,'%f');
end

i=0;
while feof(fid)==0
     i=i+1;
     time(i,1)=data(2);
     for j=3:length(data)
        pos(i,j-2)=data(j);
     end
     line=fgetl(fid);
     data=sscanf(line,'%f');
end

     i=i+1;
     time(i,1)=data(2);
     for j=3:length(data)
        pos(i,j-2)=data(j);
     end
     line=fgetl(fid);

[n,nc]=size(pos);
time=time(1:n,1);

