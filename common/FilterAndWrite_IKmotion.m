clear
cd 'S:\Human Performance Lab\MotionAnalysis\Soccer ACL 10-12 yo';
[infile,inpath]=uigetfile('*.sto');

fid=fopen([inpath infile],'r');
disp(['Loading file...' infile] );

%read the file info lines
for i=1:10
    line=fgetl(fid);
    name=sscanf(line,'%s');
    header(i,1)=cellstr(name);
end

% Load the headers
line=fgetl(fid);
j=1; i=1;
jl=length(line);
while j<jl
    name=sscanf(line(j:jl),'%s',1);
    ii = findstr(line(j:jl), name);
    j=j+ii(1)+length(name);
    headers(i,1)=cellstr(name); i=i+1;
end
headers=headers(:,1);

% Now load the data
i=0; clear line data
while feof(fid)==0
    i=i+1;
    line=fgetl(fid);
    data(i,:)=sscanf(line,'%f');
end
fclose(fid);

% ReWrite ik File
% npts = length(data);

input_file = strrep(infile, '.sto', '_filter.sto');

fid = fopen([inpath,input_file],'w');

% Write the header
for i=1:size(header,1)
    fprintf(fid,'%s\n',char(header(i)));
end

for i=1:size(headers,1)
    fprintf(fid,'%s\t',char(headers(i)));
end

samp_rate=1/(data(3,1)-data(2,1));
% Filter and write the data
[B,A] = butter(4,30/(samp_rate/2));
data(:,2:size(data,2))=filtfilt(B,A,data(:,2:size(data,2)));

for i=1:length(data)
    fprintf(fid,'%10f\t',data(i,:));
    fprintf(fid,'\n');
end

fclose(fid);
