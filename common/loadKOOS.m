function [WOMKOOS] = loadKOOS(subjects) ;

basedir = 'W:\OA_GaitRetraining\DATA\' ;
addpath(genpath('W:\OA_GaitRetraining\Matlab\common'));
weeks = [2 7 11 25 39 52] ;

if ~exist('subjects','var')
    subjectFnames = dir([basedir 'Subject1*']) ; subjectList = {subjectFnames.name} ;
    subjects = cell2mat(cellfun(@(x) str2num(x(8:10)),subjectList,'UniformOutput',false)) ;
end

WOMKOOS.subjects = subjects ;
WOMKOOS.womacPain = repmat([NaN],length(subjects),6);
WOMKOOS.womacFxn = repmat([NaN],length(subjects),6);
WOMKOOS.KOOStotal = repmat([NaN],length(subjects),6);
WOMKOOS.week = weeks ;
for i = 1:length(weeks)
    eval(['WOMKOOS.weekInds.Wk' num2str(weeks(i)) ' = find(weeks==weeks(i));']) ;
end

for sub = 1:length(subjects)
    subject = subjects(sub) ;
    cd([basedir 'Subject' num2str(subject) '\Paperwork\']) ;
    flist = dir('KOOS_W*.csv') ; fname = {flist.name} ;
    % Find week numbers
    clear wkNum
    if length(fname) >0 ;
    for fnum = 1:length(fname)
        startNum = strfind(fname{fnum},'k') ;
        for i = 1:2
            character = fname{fnum}(startNum+i) ;
            [~, status] = str2num(character) ;
            if status == 1
                wkNumString(i) = fname{fnum}(startNum+i) ;
            end
            wkNum(fnum) = str2num(wkNumString) ;
            if i==2 ; clear wkNumString ; end
        end        
    end
    wkNum = sort(wkNum) ;
    
    for wk = 1:length(fname)
        ind_wk = find(wkNum(wk)==weeks) ;
        if ~isempty(ind_wk)
            %%%% indicies
            try
                loadFname = ['KOOS_Wk' num2str(wkNum(wk)) '.csv'] ;
                KOOS = importKOOS(loadFname) ;
            catch
                loadFname = ['KOOS_Week' num2str(wkNum(wk)) '.csv'] ;
                try
                    KOOS = importKOOS(loadFname) ;
                catch
                    error(['KOOS naming wrong for Subject ' num2str(subject)]) ;
                end
            end
            womacPainStart = find(strncmp('P5',KOOS(:,1),2)) ;
            womacFxnStart = find(strncmp('A2.',KOOS(:,1),3)) - 1 ;
            KOOStotalInd = find(strncmp('Total Knee',KOOS(:,2),10)) ;

            %%%% Give warnings if KOOS is incomplete
            warning on
%             wkNum(wk)
%             sum(double(cellfun('isempty',KOOS(:,1))))             
            if sum(double(~cellfun('isempty',KOOS(:,1)))) < 42
                warning(['Subject ' num2str(subject) ' has an incomplete KOOS Wk ' num2str(wkNum(wk)) '.'])
                womacPain = nan ;
                womacFxn = nan ;
                KOOStotal = nan ;
            else
                % all the data is here
                womacPain = sum(cell2mat(KOOS(womacPainStart:womacPainStart+4,3))) ;
                womacFxn = sum(cell2mat(KOOS(womacFxnStart:womacFxnStart+16,3))) ;
                KOOStotal = cell2mat(KOOS(KOOStotalInd,3)) ;
            end

            %%%% store it
            WOMKOOS.womacPain(sub,ind_wk) = womacPain /20 *100 ;
            WOMKOOS.womacFxn(sub,ind_wk) = womacFxn / 68 *100 ;
            WOMKOOS.KOOStotal(sub,ind_wk) = KOOStotal ;
        end
    end
    end
end