function DATES = getVisitDates(subjects) ;

weeks = [1 2 7 11 25 39 52] ;
elapsedInd = 2 ; % base things off wk2 visit

DATES.datenum = cell(length(subjects),length(weeks)) ;
fx = @(x) any(isempty(x)) ;
ind = cellfun(fx,DATES.datenum) ;
DATES.datenum(ind) = {nan} ;
DATES.elapsedWks = nan(length(subjects),length(weeks)) ;

for i = 1:length(subjects)
    subject = subjects(i) ;
    thisDateNum = zeros(length(weeks)) ;
    for j = 1:length(weeks)
        wk = weeks(j) ;
        if isfolder(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\Week' num2str(wk) '\VCFiles'])
            fInfo = dir(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\Week' num2str(wk) '\VCFiles\static1\static1.vc7*']) ;
            if isempty(fInfo)
                fInfo = dir(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\Week' num2str(wk) '\VCFiles\CalFrame\CalFrame.vc7']) ;
                if isempty(fInfo)
                    fInfo = dir(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\Week' num2str(wk) '\VCFiles\CalFrame_TM\CalFrame_TM.vc7']) ;
                end
                if isempty(fInfo)
                    fInfo = dir(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\Week' num2str(wk) '\VCFiles\CalFrameTM\CalFrameTM.vc7']) ;
                end
                
            end
            thisDateNum(j) = datenum(fInfo(1).date,'dd-mmm-yyyy HH:MM:SS') ;
            DATES.datenum{i,j} = datestr(thisDateNum(j),'yyyy-mm-dd') ;
            DATES.elapsedWks(i,j) = daysact(thisDateNum(elapsedInd),thisDateNum(j))/7 ;
            if thisDateNum(j) < thisDateNum(elapsedInd) && j == elapsedInd
                DATES.elapsedWks(i,1) = -daysact(thisDateNum(1),thisDateNum(elapsedInd)) / 7 ;
            end
        end
    end
end

DATES.weeks = weeks ;
DATES.subjects = subjects ;