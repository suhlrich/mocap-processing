function [kjc] = calc_kjc(markers,T_TCS_ACSstruct,leg)
% Variable Descriptions
% markers = nsamples x 6 from R to left: Rkneexyz, Rshankxyz, Ranklexyz, Lkneexyz, Lshankxyz, Lanklexyz
% T_TCS_ACS = struct with .r and .l transformation matrix from tracking
% shank (origin outside knee) to anatomic shank with origin at kjc
% leg = 'r' or 'l'

%% FOR TESTING AS A SCRIPT
% forces = forces_SWin ;
% leg = DATA.leg;
% nargin = 5 ;
% goodtrials = PROC.EMG_goodtrials ;
% step_frames = recframes_1 ;
% markers = markers_KJC ;
% T_TCS_ACSstruct = T_TCS_ACS ;
% threshold = 150 ;
% anklemarkers_ML = anklemarkers ;

%%
% Define knee joint center
kjc = zeros(size(markers,1),3) ;
for i = 1:size(markers,1)
    if leg == 'r'
        knee = markers(i,1:3)' ; % 3x1 col vecs
        shan = markers(i,4:6)' ;
        ankl = markers(i,7:9)' ;
        ytcs = shan-knee ; ytcs = ytcs/norm(ytcs) ;
        xtcs = cross(knee-ankl,ytcs) ; xtcs = xtcs/norm(xtcs) ;
        ztcs = cross(xtcs,ytcs) ;
        T_lab_TCS = [[xtcs;0],[ytcs;0],[ztcs;0],[knee;1]] ;
        T_TCS_ACS1 = T_TCS_ACSstruct.r ;
        KFM_multiplier = -1 ;
    elseif leg == 'l'
        knee = markers(i,10:12)' ; % 3x1 col vecs
        shan = markers(i,13:15)' ;
        ankl = markers(i,16:18)' ;
        ytcs = shan-knee ; ytcs = ytcs/norm(ytcs) ;
        xtcs = cross(knee-ankl,ytcs) ; xtcs = xtcs/norm(xtcs) ;
        ztcs = cross(xtcs,ytcs) ;
        T_lab_TCS = [[xtcs;0],[ytcs;0],[ztcs;0],[knee;1]] ;
        T_TCS_ACS1 = T_TCS_ACSstruct.l ;
        KFM_multiplier = 1 ;
    else
    disp('you typed the wrong leg symbols, should be ''r'' or ''l''')
    end
    if max(abs(T_TCS_ACS1(1:3,4)))>10 % this is a bad way to see if T_TCS_ACS was recorded in mms
       T_TCS_ACS1(1:3,4) = T_TCS_ACS1(1:3,4)/1000 ;
    end
    T_lab_ACS = T_lab_TCS * T_TCS_ACS1 ;
    kjc(i,:) = T_lab_ACS(1:3,4)' ;
end 


