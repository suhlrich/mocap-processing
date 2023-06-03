function T_TCS_ACS = calc_T_static(header_static,data_static)

    k_ind_r = strmatch('r_knee',header_static.markername); 
    a_ind_r = strmatch('r_ankle',header_static.markername);
    s_ind_r = strmatch('r_shank(antsup)',header_static.markername);
    mk_ind_r = strmatch('r_mknee',header_static.markername);
    ma_ind_r = strmatch('r_mankle',header_static.markername);
    if isempty(s_ind_r) == 1 ; s_ind_r = strmatch('r_shank',header_static.markername); end % Old marker names Grr.

    k_ind_l = strmatch('L_knee',header_static.markername); 
    a_ind_l = strmatch('L_ankle',header_static.markername);
    s_ind_l = strmatch('L_shank(ant_sup)',header_static.markername);
    mk_ind_l = strmatch('L_mknee',header_static.markername);
    ma_ind_l = strmatch('L_mankle',header_static.markername);
    if isempty(s_ind_l) == 1 ; s_ind_l = strmatch('L_shank',header_static.markername); end % Old marker names Grr.

    
        r_knee = mean(data_static(:,k_ind_r:k_ind_r+2)) ;
        r_shan = mean(data_static(:,s_ind_r:s_ind_r+2)) ;
        r_ankl = mean(data_static(:,a_ind_r:a_ind_r+2)) ;
        r_mkne = mean(data_static(:,mk_ind_r:mk_ind_r+2)) ;
        r_mank = mean(data_static(:,ma_ind_r:ma_ind_r+2)) ;
        l_knee = mean(data_static(:,k_ind_l:k_ind_l+2)) ;
        l_shan = mean(data_static(:,s_ind_l:s_ind_l+2)) ;
        l_ankl = mean(data_static(:,a_ind_l:a_ind_l+2)) ;
        l_mkne = mean(data_static(:,mk_ind_l:mk_ind_l+2)) ;
        l_mank = mean(data_static(:,ma_ind_l:ma_ind_l+2)) ;
        
        % Create transormation matrix from tracking coord to anatomical
        % coord
        r_kjc = (r_mkne+r_knee) /2 ;
        r_ajc = (r_mank+r_ankl) /2 ;
        l_kjc = (l_knee+l_mkne) /2 ;
        l_ajc = (l_ankl+l_mank) /2 ;
        
        r_yacs = r_mkne-r_kjc ; r_yacs = r_yacs/norm(r_yacs) ;
        r_xacs = cross(r_kjc-r_ajc,r_yacs) ; r_xacs = r_xacs/norm(r_xacs) ;
        r_zacs = cross(r_xacs,r_yacs) ; r_zacs = r_zacs/norm(r_zacs) ;
        l_yacs = l_mkne-l_kjc ; l_yacs = l_yacs/norm(l_yacs) ;
        l_xacs = cross(l_kjc-l_ajc,l_yacs) ; l_xacs = l_xacs/norm(l_xacs) ;
        l_zacs = cross(l_xacs,l_yacs) ; l_zacs = l_zacs/norm(l_zacs) ; 
        
%         l_yacs = l_knee-l_kjc ; l_yacs = l_yacs/norm(l_yacs) ;
%         l_xacs = cross(l_kjc-l_ajc,l_yacs) ; l_xacs = l_xacs/norm(l_xacs) ;
%         l_zacs = cross(l_xacs,l_yacs) ; l_zacs = l_zacs/norm(l_zacs) ;
        r_T_lab_ACS = [[r_xacs';0],[r_yacs';0],[r_zacs';0],[r_kjc';1]] ;
        l_T_lab_ACS = [[l_xacs';0],[l_yacs';0],[l_zacs';0],[l_kjc';1]] ;

 
        r_ytcs = r_shan-r_knee ; r_ytcs = r_ytcs/norm(r_ytcs) ;
        r_xtcs = cross(r_knee-r_ankl,r_ytcs) ; r_xtcs = r_xtcs/norm(r_xtcs) ;
        r_ztcs = cross(r_xtcs,r_ytcs) ;
        l_ytcs = l_shan-l_knee ; l_ytcs = l_ytcs/norm(l_ytcs) ;
        l_xtcs = cross(l_knee-l_ankl,l_ytcs) ; l_xtcs = l_xtcs/norm(l_xtcs) ;
        l_ztcs = cross(l_xtcs,l_ytcs) ;

        
        l_T_lab_TCS = [[l_xtcs';0],[l_ytcs';0],[l_ztcs';0],[l_knee';1]] ;
        r_T_lab_TCS = [[r_xtcs';0],[r_ytcs';0],[r_ztcs';0],[r_knee';1]] ; 

        T_TCS_ACS.r = inv(r_T_lab_TCS)*r_T_lab_ACS ;
        T_TCS_ACS.l = inv(l_T_lab_TCS)*l_T_lab_ACS ;
