function [forces_proc_meters] = Analog2Force_TMrunning(forcesV,TreadmillCalibMatrix,filtfreq,samp_rate,threshold_high,threshold_low) ;
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
    [B_f,A_f] = butter(2,filtfreq/(samp_rate/2)) ; 
    forces_filt= filtfilt(B_f,A_f,forcesV) ;
%     forces_filt = CriticallyDampedFilter(forcesV,2,[],filtfreq,samp_rate);  
%     disp('applied Critically Damped Filter')
else
    disp('Warning: Did not filter')
    forces_filt = forcesV ;
end

% % From Amy's code: C:\...DelpResearch\ExampleFiles\CombineTMforces_Amy.m
offset=[0 0 0.0115; 0 0 0.0115]';
% R       transformation matrix to convert from the forceplate
%         reference frame to the motion capture reference frame
%         x-forward, y-left, z-up
R=[0 1 0; 1 0 0; 0 0 -1];
T=[R zeros(size(R)); zeros(size(R)) R];
% % % % % % % % %% 


h = 0.0115 ; %meters, height of belt off coordinate system
forces_units = zeros(size(forcesV)) ; % Converted into N and Nm - filtered (Fx, Fy, Fz, Mx, My, Mz)
unfilteredforces_units = forces_units ; % Convereted into N and Nm - unfiltered (Fx, Fy, Fz, Mx, My, Mz)
forces_proc = zeros(size(forcesV,1),14) ; % Matrix with calculated stuff (Fx, Fy, Fz, COPx, COPy, COPz, Tz)
CalibMat12 = [TreadmillCalibMatrix.r,zeros(6,6);zeros(6,6),TreadmillCalibMatrix.l] ;

forces_units = (CalibMat12*forces_filt')' ;
unfilteredforces_units = (CalibMat12*unfiltered')' ;
%Add the forces, convert moments to lab reference frame, then compute
%center of pressure

% Forces are exported in the local force plate reference frame (not electrical frame) in an
% *.anc file

ForMom=zeros(length(forces_units),6);
for i=1:2
    FPData=-forces_units(:,1+(i-1)*6:i*6)*T; % Changes force plate data from FP reference frame to lab reference frame. Negative forces and moments to act on the person
    toffset=cross(ones(size(FPData,1),1)*(-R*offset(1:3,i))',FPData(:,1:3)); % % %This is different than what Amy did.
    FPData(:,4:6)=FPData(:,4:6)+toffset;
    if i==2 % Convert the left FP moments (force plate #2) into the right FP (force plate #2) reference frame, cross(r,F).
        r=[0 0.7299+0.2413 0];
        FPData(:,4:6)=cross(ones(length(FPData),1)*r,FPData(:,1:3))+FPData(:,4:6);
    end
    ForMom=ForMom+FPData; % Sum the forces and moments. This is okay because moments are in the lab reference frame.
end

%ForMom now contains summed forces and moments for both force plates
%about the lab origin. Time to get COP
COPx=(-ForMom(:,5)./ForMom(:,3)); 
COPy=(ForMom(:,4)./ForMom(:,3));
COPz=h*ones(length(ForMom),1); % COPz == h because lab coordinate system is at treadmill surface below the wearplate and belt, so forces are applied at z=h
Tz = ForMom(:,6) + COPy.*ForMom(:,1) - COPx.*ForMom(:,2)  ; % From Mocap notebook: Mz + dot((r_origin2COP x F),nz); already a reaction torque

% Build [Fx Fy Fz COPx COPy COPz Tz] columns
forces_proc = [ForMom(:,1:3), COPx, COPy, COPz, Tz] ;

% unfilteredforces_units #3 and #9 = unfiltered vertical forces in Newtons
forces_proc(:,3) = unfilteredforces_units(:,3) + unfilteredforces_units(:,9) ;

unfilteredForces = (-R*(unfilteredforces_units(:,1:3) + unfilteredforces_units(:,7:9))')' ;

RLinds = [1 7 3] ; % Right and left indicies, [first,last,Fz]
forces_proc_2 = FiltBertecForces(forces_proc,RLinds,samp_rate,filtfreq,threshold_high,threshold_low) ;
forces_proc_meters = forces_proc_2 ;

% Plot filtered forces vs unfiltered forces
figure(100)
ynames = {'Fx','Fy','Fz','COPx','COPy','Tz'} ;
plotInds = [1:5,7] ;
for i = 1:6
    subplot(2,3,i)
    if i<=3
    plot(unfilteredForces(:,plotInds(i))) ;
    end
    hold on
    plot(forces_proc_meters(:,plotInds(i))) ;
    ylabel(ynames{i})
end


if isempty(filtfreq) == 1 ;
    forces_proc_meters = forces_proc ;
end