function [forces_proc_meters] = Analog2Force_TM_Julie(forcesV,TreadmillCalibMatrix,filtfreq,samp_rate,threshold_high,threshold_low) ;
% [Fxyz_1 COPxyz_1 Tz_1 Fxyz_2 COPxyz_2 Tz_2]

% %%% For testing as script %%%
% forcesV = forceraw ; % This is for running it as a script
% filtfreq = 9 ;
% samprate = samp_rate ;
% threshold_high = thresh_high ;
% threshold_low = thresh_low ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filter first
unfiltered = forcesV ;

%

if isempty(filtfreq) == 0
%     [B_f,A_f] = butter(4,filtfreq/(samp_rate/2)) ; 
%     forces_filt= filtfilt(B_f,A_f,forcesV) ;
    forces_filt = CriticallyDampedFilter(forcesV,2,[],filtfreq,samp_rate);  
    disp('applied Critically Damped Filter')
else
    disp('Warning: Did not filter')
    forces_filt = forcesV ;
end

%

h = 0.0095 ; %meters, height of belt off coordinate system
forces_units = zeros(size(forcesV)) ; % Converted into N and Nm - filtered (Fx, Fy, Fz, Mx, My, Mz)
unfilteredforces_units = forces_units ; % Convereted into N and Nm - unfiltered (Fx, Fy, Fz, Mx, My, Mz)
forces_proc = zeros(size(forcesV,1),14) ; % Matrix with calculated stuff (Fx, Fy, Fz, COPx, COPy, COPz, Tz)
CalibMat12 = [TreadmillCalibMatrix.r,zeros(6,6);zeros(6,6),TreadmillCalibMatrix.l] ;

    forces_units= (CalibMat12*forces_filt')' ;
    unfilteredforces_units = (CalibMat12*unfiltered')' ;
for ii = 1:size(forcesV,1)

    %This comes from 'Data Acquisition and Loads' notebook page
    %For the next few lines, ax, ay, az are in bertec treadmill frameclose
    %COPx = (-h*Fx-My)/Fz ; COPy = (-h*Fy-Mx)/Fz ; 
    %Tz = Mz - COPx*Fy+COPy*Fx
    COPax1 = (-h*forces_units(ii,1)-forces_units(ii,5)) / forces_units(ii,3) ;
    COPay1 = (-h*forces_units(ii,2)+forces_units(ii,4)) / forces_units(ii,3) ;
    Taz1 = forces_units(ii,6)-COPax1*forces_units(ii,2)+COPay1*forces_units(ii,1) ;
    COPax2 = (-h*forces_units(ii,7)-forces_units(ii,11)) / forces_units(ii,9) ;
    COPay2 =(-h*forces_units(ii,8)+forces_units(ii,10)) / forces_units(ii,9) ;
    Taz2 = forces_units(ii,12)-COPax2*forces_units(ii,8)+COPay2*forces_units(ii,7) ;
    %We will now fill the forces_proc matrix using the global frame which has the same origin, but different orientation
    
    % FOR FP1: Fx = Fay; Fy = Fax; Fz = -Faz ; COPx = COPay ; COPy = COPax ; COPz = 0 ; Tz = -Taz ;
    % BUT, we negate all forces to turn into reaction forces 
    forces_proc(ii,1:7) = [-forces_units(ii,2) -forces_units(ii,1) forces_units(ii,3) ...
        COPay1 COPax1 h Taz1] ;
    % FOR FP2: Fz = Fay; Fy = Fax; Fz = -Faz ; COPx = COPay ; COPy = COPax + .9712 m ; COPz = 0 ; Tz = -Taz 
    % BUT, we negate all forces to turn into reaction forces
    forces_proc(ii,8:14) = [-forces_units(ii,8) -forces_units(ii,7) forces_units(ii,9) ...
        COPay2 COPax2+0.9712 h Taz2] ;
end

%

% unfilteredforces_units #3 and #9 = unfiltered vertical forces in Newtons
forces_proc(:,3) = unfilteredforces_units(:,3) ;
forces_proc(:,10) = unfilteredforces_units(:,9) ;

RLinds = [1 7 3;8 14 10] ; % Right and left indicies 
forces_proc_2 = FiltBertecForces_Julie(forces_proc,RLinds,samp_rate,filtfreq,threshold_high,threshold_low) ;
forces_proc_meters = forces_proc_2 ;

if isempty(filtfreq) == 1 ;
    forces_proc_meters = forces_proc ;
end