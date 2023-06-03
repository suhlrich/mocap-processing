function [u sd traces] = ...
    calc_kjcML(forces,markers,T_TCS_ACSstruct,leg,threshold,step_frames,goodtrials)
% Variable Descriptions
% forces = matrix with Fx, Fy, Fz, COPx, COPy, COPz  for R, then L as columns (m,N)
% markers = nsamples x 6 from R to left: Rkneexyz, Rshankxyz, Ranklexyz, Lkneexyz, Lshankxyz, Lanklexyz
% T_TCS_ACS = struct with .r and .l transformation matrix from tracking
% shank (origin outside knee) to anatomic shank with origin at kjc
% leg = 'r' or 'l'
% step_frames: frame numbers for each step in a nsteps x nsamples matrix
%    |-> if this is specified, all outputs are in nsteps x 101
%    matricies and correspond with nsteps indicies used in DATA, if not,
%    they are solely output with the matrix framestarttime, indicating the
%    marker frame which the stepwidth starts
% stepwidths = nframes x 101 matrix indexed by framestart as marker frame
%    for which the r/l step started
% threshold = Force threshold for begin step (N)

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

if nargin<5
    threshold = 100 ; % 50N default threshold
end

% Define Forces
Fz_r = forces(:,3) ;
Fz_l = forces(:,9) ;


% Define knee joint center
for legnum = 1:2
    kjc = zeros(size(forces,1),3) ;
    for i = 1:size(markers,1)
        if legnum == 1 ; legselect = 'r' ; else legselect = 'l' ; end
    if legselect == 'r'
        knee = markers(i,1:3)' ; % 3x1 col vecs
        shan = markers(i,4:6)' ;
        ankl = markers(i,7:9)' ;
        ytcs = shan-knee ; ytcs = ytcs/norm(ytcs) ;
        xtcs = cross(knee-ankl,ytcs) ; xtcs = xtcs/norm(xtcs) ;
        ztcs = cross(xtcs,ytcs) ;
        T_lab_TCS = [[xtcs;0],[ytcs;0],[ztcs;0],[knee;1]] ;
        T_TCS_ACS1 = T_TCS_ACSstruct.r ;
        KFM_multiplier = -1 ;
    elseif legselect == 'l'
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
end %i
    if legselect == 'r' ; KJCy_r = kjc(:,2) ; 
    else ; KJCy_l = kjc(:,2) ;
    end
end

% Preallocate matrices and constants
clear i frames* c_* KJCstep*
c_r = 1 ; c_l = 1 ;
KJCstep_r = zeros(200,1) ; KJCstep_l = zeros(200,1) ;
KJCinterp_r = zeros(1,101) ; KJCinterp_l = zeros(1,101) ;
row_r = 1; row_l = 1 ;
firstfoot = [] ;

for i = 1:size(forces,1)
    if Fz_r(i)>threshold
        KJCstep_r(c_r) = KJCy_r(i) ;
        if c_r == 1 ; 
            start_r = i ; 
        end
            c_r = c_r + 1 ;
    elseif c_r>2
        frames_r(row_r,1:length(start_r:(i-1))) = start_r:(i-1) ;
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_r = 1 ;
        KJCinterp_r(row_r,:) = interp1(0:length(find(KJCstep_r))-1, ...
            KJCstep_r(find(KJCstep_r)),linspace(0,length(find(KJCstep_r))-1,101)) ;
        KJCstep_r = zeros(size(KJCstep_r)) ;
        row_r = row_r +1 ;
    end 
    if Fz_l(i)>threshold
        KJCstep_l(c_l) = KJCy_l(i) ;
        if c_l == 1; 
            start_l = i ; 
        end
        c_l = c_l +1 ;
    elseif c_l>2
        frames_l(row_l,1:length(start_l:(i-1))) = start_l:(i-1) ; 
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_l = 1 ;
        KJCinterp_l(row_l,:) = interp1(0:length(find(KJCstep_l))-1, ...
            KJCstep_l(find(KJCstep_l)),linspace(0,length(find(KJCstep_l))-1,101)) ;
        KJCstep_l = zeros(size(KJCstep_l)) ;
        row_l = row_l +1 ;
    end 
    if sum([row_r row_l] == 2) >0 && isempty(firstfoot) == 1 % Determine which foot hit first
        if row_r ==2; firstfoot = 'r' ; else firstfoot = 'l' ; end
    end
end %i

%% Map adjacent steps onto each other, always right foot first
if firstfoot == 'l'
    KJCinterp_l = KJCinterp_l(2:end,:) ;
    frames_l = frames_l(2:end,:) ;
end
endrow = min([size(KJCinterp_r,1) size(KJCinterp_l,1)]) ;
KJCinterp_l = KJCinterp_l(1:endrow,:) ;
KJCinterp_r = KJCinterp_r(1:endrow,:) ;

stepwidth_original = KJCinterp_l - KJCinterp_r ;

if leg == 'r'
    beginframes = frames_r(1:endrow,1) ;
else
    beginframes = frames_l(1:endrow,1) ;
end

if exist('step_frames') == 1
    recframes = step_frames ;
    stepwidth_rec = zeros(size(recframes,1),101) ;
    recvec = recframes(:,1) ;
    for i = 1:length(recvec)
        [a ind] = min(abs(beginframes-recvec(i))) ; 
        if a <20 && recvec(i)~=0
            stepwidth_rec(i,:) = stepwidth_original(ind,:) ;  
        end
    end
    if nargin>4
        stepwidth = stepwidth_rec(goodtrials,:) ;
    else
        stepwidth = stepwidth_rec ;
    end
end

if length(find(stepwidth(:,1)~= 0)) < length(goodtrials)
    disp('Fewer KJC trials than goodtrials entered, threshold likely too low')
    fprintf('%i Trials in stepwidth, but they were removed for avg\n',length(find(stepwidth(:,1)~= 0)))
end

u = mean(stepwidth(find(stepwidth(:,1)~=0),:)) ;
sd = std(stepwidth(find(stepwidth(:,1)~=0),:)) ;
traces = stepwidth ;
