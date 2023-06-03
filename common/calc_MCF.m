function [MCF] = calc_MCF(KAM,KFM) 
% Calculates estimated medial contact force using KAM and KFM peaks based
% on Manal 2015 and Walter 2010 regressions. MCF = .34*KAM + .13*KFM + .83.

MCF = .34*KAM + .13*abs(KFM) + .83 ;