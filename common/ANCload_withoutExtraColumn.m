function [header data] = ANCload(filename)
% [header data] = ANCload(filename) ;


%  subjectdir = 'C:\Users\suhlr_000\Documents\stanford\DelpResearch\OA_GaitRetrainingDATA\DATA_backup_10_1\Subject15\'
%  filename = [subjectdir 'training_0to5min1.anc'];
% nargin = 1;

%% Initialize variables.
delimiter = '\t';
    startRow = 5;
    endRow = 7;
data = dlmread(filename,delimiter,11,0) ;
data = data(:,1:end-1) ; % theres an extra tab in the file...
N = size(data,2) ;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.

% formatSpec = [repmat('%s',1,N) '[^\n\r]']
formatSpec = repmat('%s',1,N) ;


%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Create output variable
     header.varnames = cell(1,N) ;
     header.samprates = zeros(1,N) ;
     header.ranges = zeros(1,N) ;
for i = 1:N
     column = dataArray{i} ;
     header.varnames{i} = column{1} ;
     if i>1
         csamp = dataArray{i}(2) ;
         crange = dataArray{i}(3) ;
     header.samprates(i) = str2double(csamp) ;
     header.ranges(i) = str2double(crange) ;
     end
end
