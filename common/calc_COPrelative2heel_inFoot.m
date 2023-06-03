function [traces meanVec sdVec footLength] =  calc_COPrelative2heel_inFoot(COP,staticMarkers,dynamicMarkers,leg,recframes,goodtrials)
% Calculate position of COP in a foot reference frame defined as follows:
% f_x from heel to toe
% f_z = g_z (up)
% f_y = f_z x f_x (always pointed medially) I verified that positive is
% medial on 3/2/2020
% 
% traces: n_steps x 2 (x,y position) x 101 
% mean: 2 x 101 
% COP = [COP_r_x,y,z,COP_l_x,y,z] in ground frame downsampled to camera
% rate
% Markers = r_calc, r_5meta, r_toe, l_calc, l_5meta, l_toe xyz in ground frame

% if static markers come in in millimeters
if mean(mean(staticMarkers)) > 10
    staticMarkers = staticMarkers/1000 ; 
end

if leg == 'r'
    staticMarkers = staticMarkers(:,1:9) ;
    dynamicMarkers = dynamicMarkers(:,1:9) ;
    COP_inG = COP(:,1:3) ;
    legSign = 1 ;
else % left leg
    staticMarkers = staticMarkers(:,10:18) ;
    dynamicMarkers = dynamicMarkers(:,10:18) ;
    COP_inG = COP(:,4:6) ;
    legSign = -1 ;
end

% Compute R_G_ACS
[R_TCS_ACS footLength] = calc_R_TCS_ACS(staticMarkers) ;
R_G_ACS = calc_R_G_ACS(dynamicMarkers,R_TCS_ACS) ;

nSteps = find(recframes(:,1),1,'last') ;
r_COP_heel_inG = COP_inG (:,1:3) - dynamicMarkers(:,1:3) ; % COP vector from heel in Ground

r_COP_heel_inF = zeros(length(goodtrials),3,101) ;
temp_r_COP_heel_inF = zeros(3,200) ;
k = 1 ;
for i = 1:nSteps
    if ismember(i,goodtrials)
        nFrames = find(recframes(i,:),1,'last') ;
        for j = 1:nFrames
            frame = recframes(i,j) ;
            temp_r_COP_heel_inF(:,j) = (r_COP_heel_inG(frame,:)*R_G_ACS(:,:,frame))' ;
        end
        r_COP_heel_inF(k,1,1:101) = interp101(temp_r_COP_heel_inF(1,:));
        r_COP_heel_inF(k,2,1:101) = interp101(temp_r_COP_heel_inF(2,:))*legSign;
        r_COP_heel_inF(k,3,1:101) = interp101(temp_r_COP_heel_inF(3,:));
        temp_r_COP_heel_inF = zeros(3,200) ;
        k = k+1 ;
    end
end

traces = r_COP_heel_inF(:,1:2,:) ;
meanVec = squeeze(mean(traces,1)) ;
sdVec = squeeze(std(traces,0,1)) ;

end




function [R_G_TCS footLength] = calc_R_G_TCS(markers)
    R_G_TCS = zeros(3,3,size(markers,1)) ;
    for i = 1:size(markers,1)
        heel = markers(i,1:3) ;
        meta = markers(i,4:6) ;
        toe = markers(i,7:9) ;
        
        temp_x = toe-heel ;
        x_TCS = temp_x/norm(temp_x) ;
        temp_y = cross(temp_x,meta-heel) ;
        y_TCS = temp_y/norm(temp_y) ;
        z_TCS = cross(x_TCS,y_TCS) ;
        
        footLength = norm(temp_x(1:2)) ;
        R_G_TCS(1:3,1:3,i) = [x_TCS',y_TCS',z_TCS'] ;
    end
end

function [R_TCS_ACS, footLength] = calc_R_TCS_ACS(markers)
    heel = mean(markers(:,1:3)) ;
    meta = mean(markers(:,4:6)) ;
    toe = mean(markers(:,7:9)) ;
    
    temp_x = toe-heel ; 
    x_ACS = temp_x/norm(temp_x) ;
    z_ACS = [0 0 1] ;
    y_ACS = cross(z_ACS,x_ACS) ;
    
    R_G_ACS = [x_ACS',y_ACS',z_ACS']; 
    [R_G_TCS, footLength] = calc_R_G_TCS([heel,meta,toe]) ;
    R_TCS_ACS = R_G_TCS' * R_G_ACS ;
end

function R_G_ACS = calc_R_G_ACS(markers,R_TCS_ACS)
    R_G_TCS = calc_R_G_TCS(markers) ;
    R_G_ACS = zeros(3,3,size(markers,1)) ;
    for i = 1:size(markers,1)
        R_G_ACS(1:3,1:3,i) = R_G_TCS(:,:,i) * R_TCS_ACS ;
    end
end
