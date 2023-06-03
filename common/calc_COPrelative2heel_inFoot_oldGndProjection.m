function [traces meanVec sdVec] =  calc_COPrelative2heel_inFoot_oldGndProjection(COP,markers,leg,recframes,goodtrials)
% Calculate position of COP in a foot reference frame defined as follows:
% f_x from heel to toe
% f_z = g_z
% f_y = f_z x f_x
% traces: n_steps x 2 (x,y position) x 101 
% mean: 2 x 101 
% COP = [COP_r_x,y,z,COP_l_x,y,z] in ground frame downsampled to camera
% rate
% Markers = r_calc, r_toe, l_calc, l_toe xyz in ground frame

if leg == 'r'
    markers_inG = markers(:,1:6) ;
    COP_inG = COP(:,1:3) ;
    legSign = 1 ;
else % left leg
    markers_inG = markers(:,7:12) ;
    COP_inG = COP(:,4:6) ;
    legSign = -1 ;
end

nSteps = find(recframes(:,1),1,'last') ;
r_COP_heel_inG = COP_inG (:,1:3) - markers_inG(:,1:3) ; % COP vector from heel in Ground
r_COP_heel_inG(:,3) = 0 ; % project onto ground

r_COP_heel_inF = zeros(length(goodtrials),2,101) ;
temp_r_COP_heel_inF = zeros(2,200) ;
k = 1 ;
for i = 1:nSteps
    if ismember(i,goodtrials)
        nFrames = find(recframes(i,:),1,'last') ;
        for j = 1:nFrames
            frame = recframes(i,j) ;
            f_hat_x = markers_inG(frame,4:6) - markers_inG(frame,1:3) ; f_hat_x(:,3) = 0 ; % heel to toe projected onto ground, expressed in Ground
            f_hat_x = f_hat_x/norm(f_hat_x) ;
            f_hat_y = cross([0 0 1],f_hat_x) * legSign ; % f_z x f_x = f_y
            temp_r_COP_heel_inF(:,j) = [dot(r_COP_heel_inG(frame,:),f_hat_x) dot(r_COP_heel_inG(frame,:),f_hat_y)] ;
        end
        r_COP_heel_inF(k,1,1:101) = interp101(temp_r_COP_heel_inF(1,:));
        r_COP_heel_inF(k,2,1:101) = interp101(temp_r_COP_heel_inF(2,:)); ;
        temp_r_COP_heel_inF = zeros(2,200) ;
        k = k+1 ;
    end
end

traces = r_COP_heel_inF ;
meanVec = squeeze(mean(r_COP_heel_inF,1)) ;
sdVec = squeeze(std(r_COP_heel_inF,0,1)) ;