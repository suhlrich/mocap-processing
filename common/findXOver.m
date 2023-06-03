function badXOverTrials = findXOver(rCOPx, lCOPx, rHSTO, lHSTO)
%FINDXOVER uses the center of pressure in the x direction to detect cross
%over when the x cop increase at the end of the step
%   Uses at interpolated 100 time point data structure of right and left x
%   COP values

badXOverTrials.r = [] ;
badXOverTrials.l = [] ;

% Determine when right steps are too short or too long
for i = 1:length(rHSTO(:,1))
     rHSTOlengths(i) = rHSTO(i,2) - rHSTO(i,1); % Find frame length of all steps
end
rHSTOlengths_med = median(rHSTOlengths);  % Find median step length
rHSTOlengths_max = 1.2 * rHSTOlengths_med; % Maximum step length is 1.2 x's median
rHSTOlengths_min = 0.8 * rHSTOlengths_med; % Minimum step length is 0.8 x's median
k_l = 1;
k_r = 1;
for i = 1:length(rHSTO(:,1))
    if rHSTO(i,2) - rHSTO(i,1) > rHSTOlengths_max % If the step length is larger than max, that is considered crossover
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_l).l = i - 1;
        badXOverTrials(k_l+1).l = i;
        k_r = k_r + 1;
        k_l = k_l + 2;
    elseif rHSTO(i,2) - rHSTO(i,1) < rHSTOlengths_min % Smaller than min picked up step when not a step and can just be deleted
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_l).l = i - 1;
        badXOverTrials(k_l+1).l = i;
        k_r = k_r + 1;
        k_l = k_l + 2;
    end
end

% Determine when left steps are too short or too long
for i = 1:length(lHSTO(:,1))
     lHSTOlengths(i) = lHSTO(i,2) - lHSTO(i,1); % Find frame length of all steps
end
lHSTOlengths_med = median(lHSTOlengths);  % Find medium step length
lHSTOlengths_max = 1.2 *lHSTOlengths_med; % Maximum step length is 1.2 x's median
lHSTOlengths_min = 0.8 *lHSTOlengths_med; % Minimum step length is 0.8 x's median
for i = 1:length(lHSTO(:,1))
    if lHSTO(i,2) - lHSTO(i,1) > lHSTOlengths_max % If the step length is larger than max, that is considered crossover
        badXOverTrials(k_l).l = i;
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_r+1).r = i + 1;
        k_r = k_r + 2;
        k_l = k_l + 1;
    elseif lHSTO(i,2) - lHSTO(i,1) < lHSTOlengths_min % Smaller than min picked up step when not a step and can just be deleted
        badXOverTrials(k_l).l = i;
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_r+1).r = i + 1;
        k_r = k_r + 2;
        k_l = k_l + 1;
    end
end

% Determine if xCOP increases at end of step
for i = 1:(length(rCOPx)/101-1)
    if sum(find(diff(rCOPx(i*101+1+50:i*101+1+90)) > 0))
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_l).l = i - 1;
        badXOverTrials(k_l+1).l = i;
        k_r = k_r + 1;
        k_l = k_l + 2;
    elseif sum(find(diff(lCOPx(i*101+1+50:i*101+1+90)) > 0))
        badXOverTrials(k_l).l = i;
        badXOverTrials(k_r).r = i;
        badXOverTrials(k_r+1).r = i + 1;
        k_r = k_r + 2;
        k_l = k_l + 1;
    end
end
end
