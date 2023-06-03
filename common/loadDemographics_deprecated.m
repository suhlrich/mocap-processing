function [data, structReturn] = loadDemographics(workbookFile, subjectNums, sheetName, RANGE)
%IMPORTFILE Import data from a spreadsheet
%   DATA = IMPORTFILE(FILE) reads data from the first worksheet in the
%   Microsoft Excel spreadsheet file named FILE and returns the data as a
%   cell array.
%
%   DATA = IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   DATA = IMPORTFILE(FILE,SHEET,RANGE) reads from the specified worksheet
%   and from the specified RANGE. Specify RANGE using the syntax
%   'C1:C2',where C1 and C2 are opposing corners of the region.%
% Example:
%   DemographicInformation = importfile('DemographicInformation.xlsx','Sheet1','A2:E22');
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2017/08/16 17:09:08

%% Input handling

% If no sheet is specified, read first sheet
if ~exist('sheetName','var') || isempty(sheetName)
    sheetName = 1;
end

% If no RANGE is specified, read all data
if ~exist('RANGE','var') || isempty(RANGE)
    RANGE = '';
end

%% Import the data
[~, ~, data] = xlsread(workbookFile, sheetName, RANGE);
data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),data)) = {''};

%% Spit out Group Vs. Subject vector
subjectRow = strmatch('Subject',data(1,:)) ;
structReturn.subject = cell2mat(data(2:end,subjectRow)) ;
groupRow = strmatch('Group',data(1,:)) ;
structReturn.group = data(2:end,groupRow) ;
wspeedRow = strmatch('walking speed',data(1,:)) ;
structReturn.walkingSpeed = cell2mat(data(2:end,wspeedRow)) ;
genderRow = strmatch('gender',data(1,:)) ;
structReturn.gender = data(2:end,genderRow) ;
structReturn.inds.control = find(strcmp(structReturn.group,'C')) ;
structReturn.inds.intervention = find(strcmp(structReturn.group,'I')) ;

% If asked for specific subjects
if exist('subjectNums','var')
nSubs = length(structReturn.subject) ;
% structReturn.subject = xor(ones(1,nSubs), ismember(min(structReturn.subject):max(structReturn.subject),subjectNums)) ; % trials to be excluded
subInds = find(ismember(min(structReturn.subject):max(structReturn.subject),subjectNums)) ;
structReturn.subject = structReturn.subject(subInds) ;
structReturn.group = structReturn.group(subInds) ;
structReturn.walkingSpeed = structReturn.walkingSpeed(subInds) ;
structReturn.gender = structReturn.gender(subInds) ;
structReturn.inds.control = find(strcmp(structReturn.group,'C')) ;
structReturn.inds.intervention = find(strcmp(structReturn.group,'I')) ;
structReturn.controls = structReturn.subject(structReturn.inds.control) ;
structReturn.intervention = structReturn.subject(structReturn.inds.intervention) ;
end




