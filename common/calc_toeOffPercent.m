function [u,sd,toeOffPercent_vec] = calc_toeOffPercent(recframes,goodtrials)
% recframes [=] nsteps x nsamples matrix with zeros at the end of each row
% goodtrials [=] vector referencing rows of recframes to calculate

toeOffPercent_vec = zeros(size(recframes,1)-1,1) ;
for i = 1:size(recframes,1)-1
    if sum(recframes([i,i+1],1) ~= 0) == 2 ;
        toeOffPercent_vec(i) = (max(recframes(i,:)) - recframes(i,1))/ ... 
            (recframes(i+1,1)-recframes(i,1)) * 100 ;
    end
end

u = mean(toeOffPercent_vec(goodtrials)) ;
sd = std(toeOffPercent_vec(goodtrials)) ;