function [KAM KFM KAM_ma KFM_ma time_mat GRF_FP KMlab] = calc_knee_moments(T_TCS_ACSstruct,markers,forces,leg,BW_kg,h_m,step_frames,time)
% T_TCS_ACS = transformation matrix from TCS to ACS structure with r and l
% markers = matrix with knee, shank ankle x,y,z marker positions (m)
% (kneex,kneey,kneez,shankx...)
% forces = matrix with Fx, Fy, Fz, COPx, COPy, COPz as columns (m,N)
% leg = 'r' or 'l'
% BW_kg = body weight (kg)
% h_m = height (m)
% KAM = KAM in % BW*h in prox tibial ref frame in nframes x 1
% KFM = KFM         "                        "
% step_frames: frame numbers for each step in a nsteps x nsamples matrix
%    |-> if this is specified, all outputs are in nsteps x nsamples
%    matricies
% time_mat is nsteps x nsamples matrix of times only when step_frames is
%   defined
% time = nframes x 1 vector corresponding with forces and markers

%% This is for testing as a Script
% loaded = load([subjectdir 'T_TCS_ACS.mat']) ; 
% T_TCS_ACSstruct = loadedfile.T_TCS_ACSstruct ;
% markers = markers_KMin ;
% forces = forces_KMin ;
% leg = DATA.leg ;
% BW_kg = HeightWeight.BW_kg ;
% h_m = HeightWeight.h_m ;
% step_frames = recframes ;
% time = time_m ;
% nargin = 7 ;
%%


KAM = zeros(size(markers,1),1) ; KFM = KAM ; KAM_ma = KAM ; KFM_ma = KAM ; GRF_FP = KAM ;

for i = 1:size(markers,1)
    knee = markers(i,1:3)' ; % 3x1 col vecs
    shan = markers(i,4:6)' ;
    ankl = markers(i,7:9)' ;
    F = forces(i,1:3)' ;
    COP = forces(i,4:6)' ;

    if leg == 'r'
        ytcs = shan-knee ; ytcs = ytcs/norm(ytcs) ;
        xtcs = cross(knee-ankl,ytcs) ; xtcs = xtcs/norm(xtcs) ;
        ztcs = cross(xtcs,ytcs) ;
        T_lab_TCS = [[xtcs;0],[ytcs;0],[ztcs;0],[knee;1]] ;
        T_TCS_ACS = T_TCS_ACSstruct.r ;
        KFM_multiplier = -1 ;
    elseif leg == 'l'
        ytcs = shan-knee ; ytcs = ytcs/norm(ytcs) ;
        xtcs = cross(knee-ankl,ytcs) ; xtcs = xtcs/norm(xtcs) ;
        ztcs = cross(xtcs,ytcs) ;
        T_lab_TCS = [[xtcs;0],[ytcs;0],[ztcs;0],[knee;1]] ;
        T_TCS_ACS = T_TCS_ACSstruct.l ;
        KFM_multiplier = 1 ;
    else
    disp('you typed the wrong leg symbols, should be ''r'' or ''l''')
    end
    if max(abs(T_TCS_ACS(1:3,4)))>10 % this is a bad way to see if T_TCS_ACS was recorded in mm
       T_TCS_ACS(1:3,4) = T_TCS_ACS(1:3,4)/1000 ;
    end
    T_lab_ACS = T_lab_TCS * T_TCS_ACS ;
    kjc = T_lab_ACS(1:3,4) ;
    r = COP - kjc ; % expressed in lab frame
    KM = cross(F,r); % This should be rxF, but leaving it this way - signs are compensated for later
    KM_ACS = T_lab_ACS(1:3,1:3)'*KM ; % Knee moment expressed in anatomical frame
    F_ACS = T_lab_ACS(1:3,1:3)'*F ; % GRF expressed in anatomical frame

    KAM(i) = KM_ACS(1) / (BW_kg*9.8*h_m) *100 ;
    KFM(i) = KFM_multiplier * KM_ACS(2) / (BW_kg*9.8*h_m) * 100;
    GRF_FP(i) = norm(F_ACS(2:3)) ;
    KAM_ma(i) = KM_ACS(1)/norm(F_ACS(2:3)) ;
    KFM_ma(i) = KM_ACS(2)/norm([F_ACS(1) F_ACS(3)]) ;
    KMlab(i,1:3) = KM / (BW_kg*9.8*h_m) *100;
    time_mat = 0 ;
    %testing stuff
%     Fz(i) = F(3) ;
%     KAM_lab(i) = norm(KM) ;
%     KFM_lab(i) = KM(2) ;
%     kjcy(i) = kjc(2) ;
%     COPy(i) = COP(2) ;
%     Fy(i) = F(2) ;
end %i


if nargin > 6
    recframes = step_frames ;
    KAM_mat = zeros(size(recframes)) ; time_mat = KAM_mat ; KFM_mat = KAM_mat ; KAM_ma_mat = KAM_mat; ...
    KFM_ma_mat = KAM_mat ; Fz_mat = KAM_mat ; KM_mat = KAM_mat ; GRF_FP_mat = KAM_mat ;
    
    if max(max(recframes)) > length(KAM) % more frames in matlab than cortex
        lastrecframe = max(find(max(recframes')>length(KAM),1)) - 1 ;  % Find last frame that is fully captured by cortex (if stopped cortex first :/ )
    else % more frames in cortex (how it should be)
        lastrecframe = size(recframes,1) ;
    end
    
    for ii = 1:lastrecframe
        if recframes(ii,1) ~= 0
        n = length(find(recframes(ii,:))) ;
        n_frames = range(recframes(ii,1):recframes(ii,n))+1 ;
        KAM_mat(ii,1:n_frames) = KAM(recframes(ii,1):recframes(ii,n))' ;
        time_mat(ii,1:n_frames) = time(recframes(ii,1):recframes(ii,n))' ;
        KFM_mat(ii,1:n_frames) = KFM(recframes(ii,1):recframes(ii,n))' ;
        KAM_ma_mat(ii,1:n_frames) = KAM_ma(recframes(ii,1):recframes(ii,n))' ;
        KFM_ma_mat(ii,1:n_frames) = KFM_ma(recframes(ii,1):recframes(ii,n))' ;
        GRF_FP_mat(ii,1:n_frames) = GRF_FP(recframes(ii,1):recframes(ii,n))' ;
        %testing stuff
%         Fz_mat(ii,1:n_frames) = Fz(recframes(ii,1):recframes(ii,n))' ;
%         KM_mat(ii,1:n_frames) = KFM_lab(recframes(ii,1):recframes(ii,n))' ;
        end
    end
    KAM = KAM_mat ;
    KFM = KFM_mat ;
    KAM_ma = KAM_ma_mat ;
    KFM_ma = KFM_ma_mat ;
    GRF_FP = GRF_FP_mat ;
end


%% This is if running as a script
% [KAM_mean KAM_sd KAMtrials_interp] = meanplot(KAM,time_mat,EMG_goodtrials,'KAMmeans') ;
% [KFM_mean KFM_sd KFMtrials_interp] = meanplot(KFM,time_mat,EMG_goodtrials,'KFMmeans') ;
% meanplot(KAM_ma, time_mat,EMG_goodtrials,'KAM_ma');
% meanplot(Fz_mat,time_mat,EMG_goodtrials,'Fz') ;
% [a b trials] = meanplot(KAM_mat,time_mat,EMG_goodtrials,'KAM_lab') ;
% figure
% plot(kjcy,'k')
% hold on
% plot(COPy,'r--')
% plot(Fy/max(Fy),'b')
% legend('kjcy','COPy','Fy')
% ylim([-1 2])
% figure
% plot(trials')