function [u sd traces] = ...
    calc_stepwidth(forces,leg,threshold,step_frames,goodtrials,anklemarkers_ML)
% Variable Descriptions
% forces = matrix with Fx, Fy, Fz, COPx, COPy, COPz  for R, then L as columns (m,N)
% leg = 'r' or 'l'
% step_frames: frame numbers for each step in a nsteps x nsamples matrix
%    |-> if this is specified, all outputs are in nsteps x 101
%    matricies and correspond with nsteps indicies used in DATA, if not,
%    they are solely output with the matrix framestarttime, indicating the
%    marker frame which the stepwidth starts
% stepwidths = nframes x 101 matrix indexed by framestart as marker frame
%    for which the r/l step started
% threshold = Force threshold for begin step (N)
% anklemarkers = nsamples x 4 with mediolateral positions of all 4 ankle
%    markers columns r_ankle, r_mankle, l_ankle, l_mankle

%% FOR TESTING AS A SCRIPT
% forces = forces_SWin ;
% leg = DATA.leg;
% nargin = 5 ;
% goodtrials = PROC.EMG_goodtrials ;
% step_frames = recframes_1 ;
% threshold = 150 ;
% anklemarkers_ML = anklemarkers ;

%%

if nargin<3
    threshold = 100 ; % 100 N default threshold
end

% Define Forces
Fz_r = forces(:,3) ;
Fz_l = forces(:,9) ;
COPy_r = forces(:,5) ;
COPy_l = forces(:,11) ;

% Find AJC
if exist('anklemarkers_ML')
    AJC_r = mean(anklemarkers_ML(:,1:2)')' ;
    AJC_l = mean(anklemarkers_ML(:,3:4)')' ;
else
    AJC_r = zeros(size(forces,1),1) ;
    AJC_l = zeros(size(forces,1),1) ;
end

% Preallocate matrices and constants
clear i frames* c_* COPstep*
c_r = 1 ; c_l = 1 ;
COPstep_r = zeros(200,1) ; COPstep_l = zeros(200,1) ;
COPinterp_r = zeros(1,101) ; COPinterp_l = zeros(1,101) ;
AJC_HS_r = zeros(1,1) ; AJC_HS_l = zeros(1,1) ;
row_r = 1; row_l = 1 ;
firstfoot = [] ;

for i = 1:size(forces,1)
    if Fz_r(i)>threshold
        COPstep_r(c_r) = COPy_r(i) ;
        if c_r == 1; 
            start_r = i ; 
            AJC_HS_r(row_r) = AJC_r(i) ;
        end
        c_r = c_r + 1 ;
    elseif c_r>2
        frames_r(row_r,1:length(start_r:(i-1))) = start_r:(i-1) ;
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_r = 1 ;
        COPinterp_r(row_r,:) = interp1(0:length(find(COPstep_r))-1, ...
            COPstep_r(find(COPstep_r)),linspace(0,length(find(COPstep_r))-1,101)) ;
        COPstep_r = zeros(size(COPstep_r)) ;
        row_r = row_r +1 ;
    end 
    if Fz_l(i)>threshold
        COPstep_l(c_l) = COPy_l(i) ;
        if c_l == 1; 
            start_l = i ; 
            AJC_HS_l(row_l) = AJC_l(i) ;
        end
        c_l = c_l +1 ;
    elseif c_l>2
        frames_l(row_l,1:length(start_l:(i-1))) = start_l:(i-1) ; 
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_l = 1 ;
        COPinterp_l(row_l,:) = interp1(0:length(find(COPstep_l))-1, ...
            COPstep_l(find(COPstep_l)),linspace(0,length(find(COPstep_l))-1,101)) ;
        COPstep_l = zeros(size(COPstep_l)) ;
        row_l = row_l +1 ;
    end 
    if sum([row_r row_l] == 2) >0 && isempty(firstfoot) == 1 % Determine which foot hit first
        if row_r ==2; firstfoot = 'r' ; else firstfoot = 'l' ; end
    end
end %i

%% Map adjacent steps onto each other, always right foot first
if firstfoot == 'l'
    COPinterp_l = COPinterp_l(2:end,:) ;
    frames_l = frames_l(2:end,:) ;
    AJC_HS_l = AJC_HS_l(2:end) ;
end
endrow = min([size(COPinterp_r,1) size(COPinterp_l,1)]) ;
COPinterp_l = COPinterp_l(1:endrow,:) ;
COPinterp_r = COPinterp_r(1:endrow,:) ;
AJC_HS_l = AJC_HS_l(1:endrow) ;
AJC_HS_r = AJC_HS_r(1:endrow) ;

AJC_stepwidth = AJC_HS_l - AJC_HS_r ;
stepwidth_original = COPinterp_l - COPinterp_r ;

if leg == 'r'
    beginframes = frames_r(1:endrow,1) ;
else
    beginframes = frames_l(1:endrow,1) ;
end

if nargin > 3
    recframes = step_frames ;
    stepwidth_rec = zeros(size(recframes,1),101) ;
    stepwidth_AJC_rec = zeros(size(recframes,1),1) ;
    recvec = recframes(:,1) ;
    for i = 1:length(recvec)
        [a ind] = min(abs(beginframes-recvec(i))) ;
        if a <20 && recvec(i)~=0
            stepwidth_rec(i,:) = stepwidth_original(ind,:) ;  
            stepwidth_AJC_rec(i) = AJC_stepwidth(ind) ;
        end
    end
    if nargin>4
        stepwidth = stepwidth_rec(goodtrials,:) ;
        AJC_stepwidth = stepwidth_AJC_rec(goodtrials) ;
    else
        stepwidth = stepwidth_rec ;
        AJC_stepwidth = stepwidth_AJC_rec ;
    end
end

if length(find(stepwidth(:,1)~= 0)) < length(goodtrials)
    disp('Fewer stepwidth trials than goodtrials entered, threshold likely too low')
    fprintf('%i Good Trials in stepwidth, but they were removed for avg\n',length(find(stepwidth(:,1)~= 0)))
end

u = mean(stepwidth(find(stepwidth(:,1)~=0),:)) ;
sd = std(stepwidth(find(stepwidth(:,1)~=0),:)) ;
traces = stepwidth ;
u_ankle = mean(AJC_stepwidth) ;
sd_ankle = std(AJC_stepwidth) ;