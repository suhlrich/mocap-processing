function OUT = trimOsimStruct(IN,t_initial,t_final,normalizeFlag)

if ~exist('normalizeFlag') ; normalizeFlag = 0 ; end

timeVec = IN.time ;

[~,indStart] = min(abs(timeVec-t_initial)) ;
[~,indStop] = min(abs(timeVec-t_final)) ;
timeTrim = timeVec(indStart:indStop,1) ;

myFields = fields(IN) ;

for i = 1:length(myFields)
    trim = IN.(myFields{i})(indStart:indStop) ;
    if normalizeFlag
       trim = interp1(timeTrim,trim,linspace(timeTrim(1),timeTrim(end),101)) ;
    end
    OUT.(myFields{i}) = trim  ;
end
