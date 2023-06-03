function [indicies_thresholded fzmatrix] = calcThresholdFz(Fzvec,threshold,matsize) 
% This thresholds vGRF above threshold and outputs indicies of steps as
% well as Fz of steps into a matrix of size matsize
% matsize = [nrows, ncols] ;
% Fzvec = nsamples x 1 vector of vGRF

step = 1 ; n = 1 ;
indicies_thresholded = zeros(matsize) ;
fzmatrix = zeros(matsize) ;
for i = 1:length(Fzvec) ;
    if Fzvec(i)>threshold
        if n == 1 && i>1
            indicies_thresholded(step,n) = i-1 ; % this is in terms of trcframes
            fzmatrix(step,n) = Fzvec(i-1) ;
            n = n+1 ;
        end
        indicies_thresholded(step,n) = i ; % this is in terms of trcframes
        fzmatrix(step,n) = Fzvec(i) ;
        n = n+1 ;
    elseif n>1
    step = step+1 ;
    n = 1 ;
    end
end

