function FPA_abs_avg = calc_FPAabs_avg(FPAraw,stancerange)
% input :
% FPAraw = nsteps x nsamp with zeros at the end
% stancerange: [percent_stance_start percent_stance_stop] ;
%     eg: stancerange = [15 40] ; to analyze over 15%-40% stance

startperc = stancerange(1)/100 ;
finishperc = stancerange(2)/100 ;

nsteps = size(FPAraw,1) ;
FPA_abs_avg = zeros(size(FPAraw,1),1) ;
for i = 1:nsteps
    n = length(find(FPAraw(i,:))) ;
    if n>5
    FPA_abs_avg(i) = mean(FPAraw(i,round(startperc*n):round(finishperc*n))) ;
    end
end
    