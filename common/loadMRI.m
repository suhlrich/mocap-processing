function [MRI] = loadMRI(subjects,filename,modality)

if ~exist('filename')
    filename = 'globalT1pdiff.txt' ;
    modality = 'dT1p' ;
end

regions = {'MedAnt','LatAnt','MedPost','LatPost','MedWB','LatWB'} ;
MRI.(modality).subjects = [] ;
MRI.(modality).regions = regions ;
disp('Loading MRI') ;

for sub = 1:length(subjects) ;
    subjects(sub)
    fullFilePath = ['W:\OA_GaitRetraining\MRI\Subject' num2str(subjects(sub)) '\' filename] ;
    isMRIdone = dir(fullFilePath) ;
    if isempty(isMRIdone)
        fprintf('MRI not processed for Subject %i.\n',subjects(sub))
        continue
    end
    
    MRI.(modality).subjects(end+1) = subjects(sub) ;
    [MRImat, MRIheader] = importMRIfile(fullFilePath) ;
    subStr = ['S',num2str(subjects(sub))] ;
    for reg = 1:length(regions)
        MRI.(modality).(subStr).allValues = MRImat ;
        MRI.(modality).(subStr).allHeaders = MRIheader ;
        meanInd = find(cellfun(@(v) ~isempty(strfind(v, 'mean')),MRIheader)) ;
        MRI.(modality).(subStr).([regions{reg} '_u']) = MRImat(reg,meanInd) ;
    end
end
end

function [mat_MRI,header_MRI] = importMRIfile( filePath )
%loads MRI data and headers

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
formatSpec = '%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filePath,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Create output variable
mat_MRI = [dataArray{1:end-1}];

%% Now the Header
formatSpec = '%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filePath,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Create output variable
header_MRI = cellfun(@(v)v{1},dataArray(1:end-1),'UniformOutput',false);

end

