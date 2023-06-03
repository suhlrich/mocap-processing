function [u sd vector] = ...
    calc_stepwidth_kinematicMidfoot(forces,leg,threshold,step_frames,goodtrials,footMarkers)
% This finds the midfoot as 70% of the distance from the heel to 2nd
% metatarsal head from White 1982 foot antrhopometry. The foot is 27cm
% long, and the distance to the MTP joint is 19cm.
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
% footMarkers = nsamples x 12 with XYZ positions of r_calc, r_toe, l_calc,
% l_toe

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

% Find ML positions
r_calc_y = footMarkers(:,2) ;
r_toe_y = footMarkers(:,5) ;
l_calc_y = footMarkers(:,8) ;
l_toe_y = footMarkers(:,11) ;

% Preallocate matrices and constants
clear i frames* c_* COPstep*
c_r = 1 ; c_l = 1 ;
COPstep_r = zeros(200,1) ; COPstep_l = zeros(200,1) ;
COPinterp_r = zeros(1,1) ; COPinterp_l = zeros(1,1) ;
row_r = 1; row_l = 1 ;
firstfoot = [] ;

for i = 1:size(forces,1)
    if Fz_r(i)>threshold
        if c_r == 1; 
            start_r = i ; 
        end
        c_r = c_r + 1 ;
    elseif c_r>2
        frames_r(row_r,1:length(start_r:(i-1))) = start_r:(i-1) ;
        midstanceTime = ceil(mean([start_r,(i-1)])) ;
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_r = 1 ;
        COPinterp_r(row_r,1) = 0.7*(r_toe_y(midstanceTime)-r_calc_y(midstanceTime)) + r_calc_y(midstanceTime) ;
        row_r = row_r +1 ;
    end 
    if Fz_l(i)>threshold
        if c_l == 1; 
            start_l = i ; 
        end
        c_l = c_l +1 ;
    elseif c_l>2
        frames_l(row_l,1:length(start_l:(i-1))) = start_l:(i-1) ; 
        midstanceTime = ceil(mean([start_l,(i-1)])) ;
        %If error here, probably have a blip force that is confusing the
        %thresholding, try increasing threshold or filtering forces
        c_l = 1 ;
        COPinterp_l(row_l,1) = 0.7*(l_toe_y(midstanceTime)-l_calc_y(midstanceTime)) + l_calc_y(midstanceTime) ; ;
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
end
endrow = min([size(COPinterp_r,1) size(COPinterp_l,1)]) ;
COPinterp_l = COPinterp_l(1:endrow,:) ;
COPinterp_r = COPinterp_r(1:endrow,:) ;

stepwidth_original = COPinterp_l - COPinterp_r ;

if leg == 'r'
    beginframes = frames_r(1:endrow,1) ;
else
    beginframes = frames_l(1:endrow,1) ;
end

if nargin > 3
    recframes = step_frames ;
    stepwidth_rec = zeros(size(recframes,1),1) ;
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
    disp('Fewer stepwidth trials than goodtrials entered, threshold likely too low')
    fprintf('%i Good Trials in stepwidth, but they were removed for avg\n',length(find(stepwidth(:,1)~= 0)))
end

vector = stepwidth ;
u = mean(vector) ;
sd = std(vector) ; 