function FPA = getFPAoverTime(KIN,subjects)

FPA.weeks = [1 7 11 25 39 52] ;
FPA.target = nan(length(subjects),1) ;
FPA.abs = nan(length(subjects),length(FPA.weeks)) ;
FPA.absError = nan(length(subjects),length(FPA.weeks)) ;
FPA.absError_normalized = nan(length(subjects),length(FPA.weeks)) ;

for i = 1:length(subjects)
    subject = subjects(i) ;
    load(['W:\OA_GaitRetraining\DATA\Subject' num2str(subject) '\Gait\FPA\FPA_target.mat']) ;
    FPA.target(i) = FPA_target ;
    for j = 1:length(FPA.weeks)
        wk = FPA.weeks(j) ;
        if wk == 1 ; trial = 'baseline_TM' ; else ; trial = 'eval_pre' ; end
        if isfield(KIN.(['S' num2str(subject)]),['Wk' num2str(wk)])
            FPA.abs(i,j) = KIN.(['S' num2str(subject)]).(['Wk' num2str(wk)]).PROC.(trial).FPA_u ;
            if wk>1
                FPA.absError(i,j) = FPA.abs(i,j) - (FPA.abs(i,1)+FPA.target(i)) ;
                if FPA.target(i) ~=0
                    FPA.absError_normalized(i,j) = FPA.absError(i,j) * -1*sign(FPA.target(i)) ; % neg value closer to baseline, pos value further from it (for intervention)
                else
                    FPA.absError_normalized(i,j) = FPA.absError(i,j); 
                end

            end
        end
    end
end


FPA.notes = 'FPA.absError_normalized is positive too big of change, negative, too little' ;
FPA.subjects = subjects ;