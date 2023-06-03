function [P1,P2] = calcKAMPeaks(KAM, x1BL, x2BL)
% calcBLPeaks calculates peak 1 and peak 2 for a KAM curve
% 
% Find Peaks
% Max peaks are within +- 10% time of peak of average BL KAM peak
% locations
range1 = round((x1BL - 10 : x1BL + 10));
delete = find(range1 > 50);
range1(delete) = [];
range2 = round((x2BL - 10 : x2BL + 10));
delete = find(range2 < 50);
range2(delete) = [];
P1 = max(KAM(min(range1):max(range1)));
P2 = max(KAM(min(range2):max(range2)));
end

