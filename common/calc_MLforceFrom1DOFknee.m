function [F_med F_lat KAM] = calc_MLforceFrom1DOFknee(osimModelPath,jointReactions,leg,KAMmult) ;

% This function computes medial and lateral forces from a scaled OpenSim
% model and joint reaction forces and calculates medial and lateral
% reaction forces. The intercondylar distance is calculated from Winby 2009
% from medial/lateral markers on the femoral epicondyles. We assume that
% the medial and lateral compartment contact points are equidistant from
% the joint center. Written by Scott Uhlrich and Julie Kolesar, Spring
% 2020.

% Joint reactions is a nSamples x 9 matrix with reaction forces, moments,
% and point of application in the tibia reference frame. Fxyz, Mxyz, Pxyz

% KAMmult artificially changes eKAM to see how it affects MCF. Default =1
if nargin<4
    KAMmult=1 ;
end

import org.opensim.modeling.*


osimModel = Model(osimModelPath);

% Medial and lateral knee marker names in OA dataset
if leg=='r'  
    KneeMkrMed = 'r_mknee';
    KneeMkrLat = 'r_knee';
else
    KneeMkrMed = 'L_mknee';
    KneeMkrLat = 'L_knee';
end

% Get positions of medial and lateral knee markers
markerSet = osimModel.getMarkerSet();

medMkrIdx = markerSet.getIndex(KneeMkrMed);
latMkrIdx = markerSet.getIndex(KneeMkrLat);
medMkr = markerSet.get(medMkrIdx);
latMkr = markerSet.get(latMkrIdx);

medMkrLoc = Vec3();
latMkrLoc = Vec3();
medMkrLoc = medMkr.get_location();
latMkrLoc = latMkr.get_location();
medMkrLoc = osimVec3ToArray(medMkrLoc);
latMkrLoc = osimVec3ToArray(latMkrLoc);

% Calculate position of Med and Lat contact points
% This uses the equation developed by Winby et al. 2009, and also included
% in the Supplementary material of Saxby et al. 2016
MkrDist = norm(medMkrLoc-latMkrLoc);
MkrDist = MkrDist*1000; %convert from m to mm
icDist = (MkrDist*0.4578+10.43)/1000 ;  % intercondyler distance in meters

%% Compute frontal plane moment balance about the lateral compartment
nSteps = size(jointReactions,1) ;
nKAMmult = length(KAMmult) ;

F_med = zeros(nSteps,nKAMmult) ;
F_lat = F_med ;
KAM = F_med ;

for i = 1:nSteps
    for j = 1:nKAMmult
%         oneBWh = BW*9.8*h_m  /100;
        M_origin = jointReactions(i,4:6) + cross(jointReactions(i,7:9),jointReactions(i,1:3)) ; % M_new = M_old + r_new_to_old x F
        F_right = jointReactions(i,2)/2 + KAMmult(j)*M_origin(1)/icDist ;

        M_originVec(i,:) = M_origin ;
        if leg == 'r'
            F_med(i,j) = F_right ; 
            F_lat(i,j) = jointReactions(i,2) - F_med(i) ;
        elseif leg == 'l'
            F_lat(i,j) = F_right ;
            F_med(i,j) = jointReactions(i,2) - F_lat(i) ;
        end
        KAM(i,j) = KAMmult(j)*M_origin(1) ;
    end
end

a=1 ;
