function [kneeAngle_interp_traces, kneeAngle_interp_u, kneeAngle_peak, kneeAngle_peak_u] = ... 
    calc_kneeFlexAngle(markers, leg, recframes,goodtrials)
% This function takes in XYZ marker data from the hip (col 1:3), knee (col 4:6), and ankle joint
% centers (col 7:9), and lateral femoral epicondyle (col 10:12) marker and calculates knee flexion 
% angles over time in degrees. From Grood and Suntay. If recframes is defined, KneeFlexion
% is returned on a step-by-step basis, if not, just one long vector

HJC = markers(:,1:3) ;
KJC = markers(:,4:6) ;
AJC = markers(:,7:9) ;
latFemCond = markers(:,10:12) ;

% Preallocate vectors
F = zeros(size(HJC,1),3);
sina = zeros(size(HJC,1),1);
KneeFlexion = zeros(size(HJC,1),1);

% Calculate femoral and tibial axes
% Vector between lateral femoral condyle and kjc
if leg == 'l'
    FemCondVec = latFemCond - KJC;
else
    FemCondVec = KJC - latFemCond;
end
% Fixed axes
k_fem = HJC - KJC; % Femur
k_tib = KJC - AJC; %Tibia

j = 1 ;
if exist('recframes')
    nSteps = find(recframes(:,1),1,'last') ;
    for i = 1:size(recframes,1)
        if ismember(i,goodtrials)
            nFrames = find(recframes(i,:),1,'last') ;
            kneeAngle_interp_traces(j,:) = interp101(calcInternalKFA(recframes(i,1:nFrames),HJC,KJC,AJC,latFemCond,FemCondVec,k_fem,k_tib)) ;
            kneeAngle_peak(j) = max(kneeAngle_interp_traces(j,1:50)) ;
            j = j+1 ;
        end
    end
    kneeAngle_interp_u = mean(kneeAngle_interp_traces) ;
    kneeAngle_peak_u = mean(kneeAngle_peak) ;
else
    kneeAngle_interp_traces = calcInternalKFA(1:length(KJC),HJC,KJC,AJC,latFemCond,FemCondVec,k_fem,k_tib) ;
    kneeAngle_interp_u = nan ;
    kneeAngle_peak = nan ;
    kneeAngle_peak_u = nan ;
end

end

function KneeFlexion = calcInternalKFA(rg,HJC,KJC,AJC,latFemCond,FemCondVec,k_fem,k_tib)
    for i = 1:length(rg)
        j = rg(i) ;
        j_fem(i,:) = cross(k_fem(j,:),FemCondVec(j,:));
        i_fem(i,:) = cross(j_fem(i,:),k_fem(j,:));
        j_tib(i,:) = cross(k_tib(j,:),FemCondVec(j,:));
        i_tib(i,:) = cross(k_fem(j,:),j_fem(i,:));
        % Unit vectors
        e3(i,:)=k_tib(j,:)/norm(k_tib(j,:));
        e1(i,:)=i_fem(i,:)/norm(i_fem(i,:));
        % Floating axis
        F(i,:) = cross(e1(i,:),e3(i,:));
        % Flexion angle
        sina(i,:) = dot(-F(i,:),k_fem(j,:));
        KneeFlexion(i) = asind(sina(i));
    end
end