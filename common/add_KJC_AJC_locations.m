function [header_new,data_new] = add_KJC_AJC_locations(header,data,T_TCS_ACS_knee,T_TCS_ACS_ankle,unitOut)

if ~exist('unitOut'); unitOut = 'm' ; end

% Location of each marker data in static matrix
    k_ind_r = strmatch('r_knee',header.markername); 
    a_ind_r = strmatch('r_ankle',header.markername);
    s_ind_r = strmatch('r_shank(antsup)',header.markername);
    mk_ind_r = strmatch('r_mknee',header.markername); % this seems unneccesary...there aren't medial knees and ankles in dynamic trials
    ma_ind_r = strmatch('r_mankle',header.markername);
    if isempty(s_ind_r) == 1 ; s_ind_r = strmatch('r_shank',header.markername); end % Old marker names Grr.

    k_ind_l = strmatch('L_knee',header.markername); 
    a_ind_l = strmatch('L_ankle',header.markername);
    s_ind_l = strmatch('L_shank(ant_sup)',header.markername);
    mk_ind_l = strmatch('L_mknee',header.markername);
    ma_ind_l = strmatch('L_mankle',header.markername);
    if isempty(s_ind_l) == 1 ; s_ind_l = strmatch('L_shank',header.markername); end % Old marker names Grr.
    
% Unit conversion to meters
    if max(abs(T_TCS_ACS_knee.r(1:3,4)))>10 % this is a bad way to see if T_TCS_ACS was recorded in mm
       T_TCS_ACS_ankle.r(1:3,4) = T_TCS_ACS_ankle.r(1:3,4)/1000 ;
       T_TCS_ACS_ankle.l(1:3,4) = T_TCS_ACS_ankle.l(1:3,4)/1000 ;
       T_TCS_ACS_knee.r(1:3,4) = T_TCS_ACS_knee.r(1:3,4)/1000 ;
       T_TCS_ACS_knee.l(1:3,4) = T_TCS_ACS_knee.l(1:3,4)/1000 ;
    end   
    
    if mean(mean(data(:,3:end))) > 10
        data(:,3:end) = data(:,3:end)/1000 ;
    end

% Get Marker Data    
        r_knee = data(:,k_ind_r:k_ind_r+2) ;
        r_shan = data(:,s_ind_r:s_ind_r+2) ;
        r_ankl = data(:,a_ind_r:a_ind_r+2) ;
        r_mkne = data(:,mk_ind_r:mk_ind_r+2) ;
        r_mank = data(:,ma_ind_r:ma_ind_r+2) ;
        l_knee = data(:,k_ind_l:k_ind_l+2);
        l_shan = data(:,s_ind_l:s_ind_l+2) ;
        l_ankl = data(:,a_ind_l:a_ind_l+2) ;
        l_mkne = data(:,mk_ind_l:mk_ind_l+2) ;
        l_mank = data(:,ma_ind_l:ma_ind_l+2) ;
        
nFrames = size(data,1) ;
newData = zeros(nFrames,12) ;

for i = 1:nFrames
% Tracking coordinate system        
    r_ytcs = r_shan(i,:)-r_knee(i,:) ; r_ytcs = r_ytcs/norm(r_ytcs) ;
    r_xtcs = cross(r_knee(i,:)-r_ankl(i,:),r_ytcs) ; r_xtcs = r_xtcs/norm(r_xtcs) ;
    r_ztcs = cross(r_xtcs,r_ytcs) ;
    l_ytcs = l_shan(i,:)-l_knee(i,:) ; l_ytcs = l_ytcs/norm(l_ytcs) ;
    l_xtcs = cross(l_knee(i,:)-l_ankl(i,:),l_ytcs) ; l_xtcs = l_xtcs/norm(l_xtcs) ;
    l_ztcs = cross(l_xtcs,l_ytcs) ;

    l_T_N_TCS = [[l_xtcs';0],[l_ytcs';0],[l_ztcs';0],[l_knee(i,:)';1]] ; 
    r_T_N_TCS = [[r_xtcs';0],[r_ytcs';0],[r_ztcs';0],[r_knee(i,:)';1]] ; 

    l_T_N_TCS_ank = [[l_xtcs';0],[l_ytcs';0],[l_ztcs';0],[l_ankl(i,:)';1]] ; 
    r_T_N_TCS_ank = [[r_xtcs';0],[r_ytcs';0],[r_ztcs';0],[r_ankl(i,:)';1]] ; 
    
    l_T_N_ACS_knee = l_T_N_TCS * T_TCS_ACS_knee.l ;
    r_T_N_ACS_knee = r_T_N_TCS * T_TCS_ACS_knee.r ;
    l_T_N_ACS_ank = l_T_N_TCS_ank * T_TCS_ACS_ankle.l ;
    r_T_N_ACS_ank = r_T_N_TCS_ank * T_TCS_ACS_ankle.r ;
    
    newData(i,:) = [r_T_N_ACS_knee(1:3,4) ; l_T_N_ACS_knee(1:3,4) ; ...
                    r_T_N_ACS_ank(1:3,4)  ; l_T_N_ACS_ank(1:3,4)]' ;
end

header_new = header ;
newLabels = {'r_KJC','','','L_KJC','','','r_AJC','','','L_AJC','',''} ;
header_new.markername = horzcat(header.markername(1:2),newLabels,header.markername(3:end)) ; % there may be some wierd marker positions at the end
data_new = horzcat(data(:,1:2),newData,data(:,3:end)) ;

if ~isempty(strmatch(unitOut,'mm','exact')) ;
    %convert to mm
    data_new(:,3:end) = data_new(:,3:end)*1000 ;
end
