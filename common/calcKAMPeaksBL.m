function [P1,P2,x1,x2] = calcKAMPeaksBL(KAM)
% Input: KAM curve, Output: [Peak 1, Peak 2, location of Peak 1, location of Peak 2] 
% calcBLPeaks calculates peak 1 and peak 2 for a KAM curve
% Find Peaks
% Peak 1 is max within first 50%
P1 = max(KAM(1:50));
x1 = find(KAM == P1);
% Peak 2 is max within second 50%
P2 = max(KAM(51:101));
x2 = find(KAM == P2);
end

