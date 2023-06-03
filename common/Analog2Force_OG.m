function [forces_proc_meters] = Analog2Force_OG(forcesV,threshold,lpFiltFreq,samp_rate) ;
% [Fxyz1 COPxyz1 Tz1 Fxyz2 COPxyz2 Tz2 Fxyz3 COPxyz3 Tz3]
disp('Incorporates updated COP for the 3rd force plate installed May 13th 2022')

% %%% For testing as script %%%
% clc
% forcesV = force_filt_V ; % This is for running it as a script
% threshold = 10 ;
% filtfreq = 9 ;
% samprate = samp_rate ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OGCalibMatrix.FP1 = diag([1000 1000 2000 600 400 300]) ;
OGCalibMatrix.FP2 = diag([1000 1000 2000 900 600 450]) ;
OGCalibMatrix.FP3 = diag([1000 1000 2000 900 600 450]) ;

h = 0.006 ; %meters, height of floor off lab coordinate system

R1 = [0 1 0; 1 0 0; 0 0 -1] ; % PT
R2 = [-1 0 0; 0 1 0; 0 0 -1] ; % Middle FP
R3 = [-1 0 0; 0 1 0; 0 0 -1] ; % Cabinets
r_elecorigin_laborigin_FP1 = [0.300 0.200 -0.006] ;
r_elecorigin_laborigin_FP2 = [0.901 0.200 -0.006] ;
r_elecorigin_laborigin_FP3 = [1.502 0.200 -0.006] ;

forces_units = zeros(size(forcesV)) ;
forces_proc = zeros(size(forcesV,1),21) ;
CalibMat18 = [OGCalibMatrix.FP1,zeros(6,12);zeros(6,6),OGCalibMatrix.FP2,zeros(6,6); ... 
    zeros(6,12),OGCalibMatrix.FP3] ;

% Filter everything with Critically Damped Filter
if isempty(lpFiltFreq) == 0
%     forces_filt = CriticallyDampedFilter(forcesV,2,[],lpFiltFreq,samp_rate);
    [B_f,A_f] = butter(2,lpFiltFreq/(samp_rate/2)) ; % was 4 til scott changed it 1/19/18. filtfilt doubles the order
    forces_filt= filtfilt(B_f,A_f,forcesV) ;
%     disp('applied Critically Damped Filter')
else
    disp('Did not filter')
    forces_filt = forcesV ;
end

for ii = 1:size(forcesV,1)
    forces_electrical = (CalibMat18*forces_filt(ii,:)')' ;
    
    % rotate forces and move to lab origin (on top of floor)
    forces_units(ii,1:3) = forces_electrical(1:3)*R1 ;
    forces_units(ii,7:9) = forces_electrical(7:9)*R2 ;
    forces_units(ii,13:15) = forces_electrical(13:15)*R3 ;
    forces_units(ii,4:6) = forces_electrical(4:6)*R1 + cross(r_elecorigin_laborigin_FP1,forces_units(ii,1:3)) ;
    forces_units(ii,10:12) = forces_electrical(10:12)*R2 + cross(r_elecorigin_laborigin_FP2,forces_units(ii,7:9)) ;
    forces_units(ii,16:18) = forces_electrical(16:18)*R3 + cross(r_elecorigin_laborigin_FP3,forces_units(ii,13:15)) ;
    
    % Compute COPs
    % COPx = -My/Fz
    % COPy = Mx/Fz
    % Tz = Mz - COPx*Fy + COPy*Fx
    for FP= 1:3
        COPx(FP) = -forces_units(ii,6*(FP-1)+5)/forces_units(ii,6*(FP-1)+3) ;
        COPy(FP) = forces_units(ii,6*(FP-1)+4)/forces_units(ii,6*(FP-1)+3) ;
        Tz(FP) = forces_units(ii,6*(FP-1)+6) - COPx(FP)*forces_units(ii,6*(FP-1)+2) + ...
                 COPy(FP)*forces_units(ii,6*(FP-1)+1) ;
    end
    
    % Compile forces and moments F1x F1y F1z COP1x COP1y COP1z T1z
    % Need to understand what lab origin is...are markers reported relative
    % to the top of the floor? or are they reported relative to the top of
    % the forceplate. If it is the top of the forceplate, the COPz=h is
    % just compensating for an offset in marker positions, and all above
    % calculations are correct.
    forces_proc(ii,:) = [-forces_units(ii,1:3) COPx(1) COPy(1) h Tz(1), ...
                         -forces_units(ii,7:9) COPx(2) COPy(2) h Tz(2), ...
                         -forces_units(ii,13:15) COPx(3) COPy(3) h Tz(3)] ;
end 

% % Critically Damped Filter for Forces and Moments
% forces_proc(:,1:3) = CriticallyDampedFilter(forces_proc(:,1:3),2,[],lpFiltFreq,samp_rate);
% forces_proc(:,7:10) = CriticallyDampedFilter(forces_proc(:,7:10),2,[],lpFiltFreq,samp_rate);
% forces_proc(:,14:17) = CriticallyDampedFilter(forces_proc(:,14:17),2,[],lpFiltFreq,samp_rate);
% forces_proc(:,21) = CriticallyDampedFilter(forces_proc(:,21),2,[],lpFiltFreq,samp_rate);

% Remove all values when foot isn't on forceplate
zero_FP1 = find(forces_proc(:,3)>threshold == 0) ;
zero_FP2 = find(forces_proc(:,10)>threshold == 0) ;
zero_FP3 = find(forces_proc(:,17)>threshold == 0) ;
forces_proc(zero_FP1,1:7) = 0 ;
forces_proc(zero_FP2,8:14) = 0 ;
forces_proc(zero_FP3,15:21) = 0 ;

forces_proc_meters = forces_proc ;

% figure
% for i = 1:21
%     subplot(3,7,i)
%     plot(forces_proc(:,i))
% end