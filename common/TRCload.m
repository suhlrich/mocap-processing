function [header, data, dataArray] = TRCload(filename)
%  subjectdir = 'C:\Users\suhlr_000\Documents\stanford\DelpResearch\OA_GaitRetrainingDATA\DATA_backup_10_1\Subject15\'
%  filename = [subjectdir 'training_0to5min1.trc'];
% nargin = 1;

%% Initialize variables.
delimiter = '\t';
    startRow = 3;
    endRow = 4;
data = dlmread(filename,delimiter,6,0) ;
data = data(:,1:end) ;
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
header.samplerate = str2double(dataArray{1,1}(1)) ;
for i = 1:N
     column = dataArray{i} ;
     header.markername{i} = column{2} ;
end
