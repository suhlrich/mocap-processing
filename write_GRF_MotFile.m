clear ; close all ; format compact ; clc
repoDir = [pwd,'\'] ;
addpath([repoDir, 'common']);

% User inputs if you'd like
dataDir = [repoDir 'Data\overgroundForces\'] ;
cd(dataDir)

freq_filtering = 12 ; % lpCutoffFreq for generic force data
freq_filtering_walk = 12; %lpCutoffFreq for walking and treadmill force data
freq_filtering_run = 15; % lpCutoffFreq for force and marker data
zero_threshold = 20 ; % forces below this go to 0

% thresholds for treadmill running
thresh_high_TMrun = 300 ; % N Everything below this goes to 0. ~300 needed for sprinting
thresh_low_TMrun = 10 ; % N Everything below this goes to 0 of the filtered version
thresh_COP_TMrun = 200 ; % N When Fz is below this, COP tracks heel and toe markers. ~200 is good for sprointing

plateNamesOG = {'R','L','3'} ; % Reset this to 1,2,3 for generality if desired
plateNamesWalking = {'R','L'} ; % Reset this to '','1_' for old style

rotateOG_xForward = false ; 

manuallySelectTrials = true;
walking= 1 ; % this does not sum the treadmill forces if true

% if not manual, change these
isGait = false ;
% gaitPrefixes = {'walking','running'}
% nonGaitPrefixes = {'squat','STS','DJ','static'}
gaitPrefixes = {'walking'} ;
nonGaitPrefixes = {'DJ','squat','STS', 'static'} ;

% % % % End user inputs

if manuallySelectTrials
% Load file(s) to be converted.
    display('Select *.anc files to convert into motion files.');
    [files,inpath]=uigetfile([dataDir '*.anc'],'Select analog files with forces','multiselect','on');
    files=cellstr(files);
    cd(inpath)
else
    if isGait
        filePrefixes = gaitPrefixes ;
        walking = true ; 
    else
        filePrefixes = nonGaitPrefixes ;
        walking = false ;
    end
    
    files = {} ;
    for i=1:length(filePrefixes)
        temp = dir([dataDir '/' filePrefixes{i} '*.anc']) ;
        files= [files, {temp(:).name}] ;
        inpath = dataDir ;
    end
end


[a b] = size(files);
for i=1:b;
    clear FPData
    clear rightmoments
    clear leftmoments
    infile=char(files(:,i));
    [samp_rate, channel_names, range, time, data, inpath, fileroot]=open_anc(inpath,infile);
%     time_forces=[time(1:size(time,1)-1)];
    time_forces = time ;
    samprate_a = samp_rate(strmatch('F1X',channel_names));

        % 16-bit system 2^16 = 65536
    % range is given in milivolts, so multiply by 0.001 to make volts
    data=(ones(size(data,1),1)*range*2).*(data/65536)*0.001; % Convert all data into volts
    
    % In this case, you are working on a treadmill trial
    if sum(ismember(channel_names,'F3X'))==0
        treadmill = true ;
        
        infile=strrep(infile,'.anc','.trc');
        forcenames = ['F1X';'F1Y';'F1Z';'M1X';'M1Y';'M1Z';'F2X';'F2Y';'F2Z';'M2X';'M2Y';'M2Z'] ;
        load TreadmillCalibMatrix.mat
        
        % Create raw matrix of forces
        forceraw = zeros(size(data,1),length(forcenames)) ;
        for p = 1:size(forcenames,1) ;
            forceindicies(p) = find(strcmp(channel_names,forcenames(p,:))) ;
            forceraw(:,p) = data(:,forceindicies(p)) ;
        end
        
        % Detect running vs. walking
        fzSum = sum(forceraw(:,[strmatch('F1Z',forcenames), strmatch('F2Z',forcenames)]),2) * TreadmillCalibMatrix.r(3,3) ;
        running = sum(fzSum<200)/length(fzSum) > .2 ; % if summed grf < 200N at least 20% of time, must be running

        if running
            disp('processing as treadmill running.')
            filt_freq = freq_filtering_run ;
            thresh_high = thresh_high_TMrun ; % N Everything below this goes to 0
            thresh_low = thresh_low_TMrun; % N Everything below this goes to 0 of the filtered version
            thresh_COP = thresh_COP_TMrun ; % N When Fz is below this, COP tracks heel and toe markers
            h = 0 ; % COPz = 0
                
            % Turning Forces from V to Newtons, Filtering, and Zeroing during swing
            % This structure includes forces and COP in the
            % following order: Fx Fy Fz COPx COPy COPz Tz
               
            forces_Nm = Analog2Force_TMrunning(forceraw,TreadmillCalibMatrix,filt_freq,samprate_a,thresh_high,thresh_low) ;
            
            % % detect if forces are acting on right or left foot here
            infile=strrep(infile,'.anc','.trc');
            [header_m data_m] = TRCload([inpath infile]) ;
            time_m = data_m(:,strmatch('Time',header_m.markername)) ;
        
            analogSampMult = samprate_a/header_m.samplerate ;
        
            % Use x position of heel marker to decide if heel strike is right
            % or left
            inds.r_calc = strmatch('r_calc',header_m.markername) ;
            inds.l_calc = strmatch('L_calc',header_m.markername) ;
            r_calc_x = data_m(:,inds.r_calc) ;
            l_calc_x = data_m(:,inds.l_calc) ;
            
            % Upsample marker data if force data hasn't been downsampled
            if length(forces_Nm)>length(r_calc_x) ;
                r_calc_x = repelem(r_calc_x,analogSampMult) ;
                l_calc_x = repelem(l_calc_x,analogSampMult) ;
            end
        
            % Detect stance phase 
            onGround = find(forces_Nm(:,3)) ; 
            HS = onGround(find(diff(onGround) > 1)+1) ; % look for large jump in time between non-zero forces
            TO = onGround(find(diff(onGround) > 1)) ;
        
            if forces_Nm(1,3) > 0 ; % if force at beginning of trial
                HS = [onGround(1)+1;HS] ; %set HS(1) to 1
                else HS = [find(forces_Nm(:,3),1,'first'); HS] ;
            end
            if forces_Nm(end,3) > 0 ; %if force at end of trial
                TO = [TO; onGround(end)-1] ; %set TO(end) to final frame 
                else TO = [TO ; find(forces_Nm(:,3),1,'last')] ;
            end
            
            % Make HS be first index and TO be last index if stance is cut 
            if HS(1) == 2 ; HS(1) = 1 ; end
            if TO(end) == length(forces_Nm)-1 ; TO(end) = length(forces_Nm) ; end
            
            stepInds(:,1) = HS ; %first column has index of HS, second column: TO
            stepInds(:,2) = TO ;
        
            % Make two separate matrices of left and right forces based on dif.
            % between x position of r and l calcaneous markers on 2nd step
            if (r_calc_x(stepInds(2,1)) - l_calc_x(stepInds(2,1)))>0 ; %second step is right foot
                r_stepInds = stepInds(2:2:length(stepInds),:) ;
                l_stepInds = stepInds(1:2:length(stepInds),:) ;
            else
                r_stepInds = stepInds(1:2:length(stepInds),:) ;
                l_stepInds = stepInds(2:2:length(stepInds),:) ;
            end
        
            r_forces_Nm = zeros(size(forces_Nm)) ;
            l_forces_Nm = r_forces_Nm ;
        
            for i =1:length(r_stepInds)
                r_forces_Nm(r_stepInds(i,1):r_stepInds(i,2),:) = forces_Nm(r_stepInds(i,1):r_stepInds(i,2),:) ;
            end
            for i =1:length(l_stepInds)
                l_forces_Nm(l_stepInds(i,1):l_stepInds(i,2),:) = forces_Nm(l_stepInds(i,1):l_stepInds(i,2),:) ;
            end
        
            % Transform forces and COP into x-forward, y-up, and z-right for
            % OpenSim
            R=[1  0  0;
                0  0 -1;
                0  1  0];
            
            r_forces_Nm = [r_forces_Nm(:,1:3)*R, r_forces_Nm(:,4:6)*R, r_forces_Nm(:,7)] ; % [Fx Fy Fz COPx COPy COPz Tz] (in lab frame)
            l_forces_Nm = [l_forces_Nm(:,1:3)*R, l_forces_Nm(:,4:6)*R, l_forces_Nm(:,7)] ;
            
            % convert COP into Julie's notation so I don't have to change variable
            % names
            
            rightforces = r_forces_Nm(:,1:3) ;
            leftforces = l_forces_Nm(:,1:3) ;
            rightCOP = r_forces_Nm(:,4:6) ;
            leftCOP = l_forces_Nm(:,4:6) ;
            rightmoments = [zeros(length(r_forces_Nm),1), r_forces_Nm(:,7), zeros(length(r_forces_Nm),1)] ; % free moment is only non-zero moment about COP, it is in the y direction in opensim
            leftmoments = [zeros(length(r_forces_Nm),1), l_forces_Nm(:,7), zeros(length(r_forces_Nm),1)] ; 
             
        %     Load *.trc file so we can make the COP the toe and heel marker
        %     projections onto the floor during early and late swing respectively.
        %     When we interpolated between COP, the COP would come zooming in from
        %     behind during early stance.
            
            inds.r_toe = strmatch('r_toe',header_m.markername) ;
            inds.l_toe = strmatch('L_toe',header_m.markername) ;
            r_calc_proj = 1/1000 * interp1(time_m,[data_m(:,inds.r_calc:inds.r_calc+1) h*ones(length(data_m),1)] * R, time_forces,'linear','extrap') ; % rotated into Opensim frame
            l_calc_proj = 1/1000 * interp1(time_m,[data_m(:,inds.l_calc:inds.l_calc+1) h*ones(length(data_m),1)] * R, time_forces,'linear','extrap') ; 
            r_toe_proj = 1/1000 * interp1(time_m,[data_m(:,inds.r_toe:inds.r_toe+1) h*ones(length(data_m),1)] * R, time_forces,'linear','extrap') ; 
            l_toe_proj = 1/1000 * interp1(time_m,[data_m(:,inds.l_toe:inds.l_toe+1) h*ones(length(data_m),1)] * R, time_forces,'linear','extrap') ; 
           
        
            
        % Right Foot COP Manipulation
            for i=1:length(r_stepInds)+1
                
                % Deal with the first step
                if i == 1 && r_stepInds(i) == 1 % if foot is on ground to start, go to next swing phase
                    i = i+1 ; 
                    toInd = r_stepInds(1,2) ;
                    hsInd = r_stepInds(2,1) ;
                    halfInd = round(mean([toInd,hsInd])) ;
                elseif i == 1 && r_stepInds(i) > 1 % if swing phase to start, make toe-off index 1
                    toInd = 1 ; 
                    hsInd = r_stepInds(i,1) ;
                    halfInd = 1 ;
                % Deal with the last step
                elseif i == length(r_stepInds)+1 && r_stepInds(i-1,2) == length(forces_Nm) % if foot is on ground to end, repeat last calculation
                    i = i-1 ; 
                    toInd = r_stepInds(end-1,2) ;
                    hsInd = r_stepInds(end,1) ;
                    halfInd = round(mean([hsInd,toInd])) ;
                elseif i == length(r_stepInds)+1 && r_stepInds(i) < length(forces_Nm) % if swing phase at end, make heel-strike last index
                    toInd = r_stepInds(end,2) ;
                    hsInd = length(forces_Nm) ; 
                    halfInd = length(forces_Nm) ; 
                elseif i >1 && i<length(r_stepInds)+1  % steps that aren't beginning or end
                    toInd = r_stepInds(i-1,2) ;        
                    hsInd = r_stepInds(i,1) ;
                    halfInd = round(mean([hsInd,toInd])) ;
                end
                
                % March backwards on toInd and forwards on hsInd until Fz > thresh_COP
                FzSample = rightforces(toInd,2);  % it is the y force in Opensim land
                while toInd>1 && FzSample<thresh_COP
                    toInd = toInd-1 ;
                    FzSample = rightforces(toInd,2) ;
                end
                FzSample = rightforces(hsInd,2) ; % it is the y force in Opensim land
                while hsInd<length(forces_Nm) && FzSample<thresh_COP
                    hsInd = hsInd + 1 ;
                    FzSample = rightforces(hsInd,2) ;
                end
                
                % Plug in Heel COP for heel strike and toe COP for toe-off
                rightCOP(toInd:halfInd,:) = r_toe_proj(toInd:halfInd,:) ; % First half of swing phase COP is at toe
                rightCOP(halfInd:hsInd,:) = r_calc_proj(halfInd:hsInd,:) ; % Second half of swing phase COP is at heel
            
                % Linearly connect junctions to avoid step discontinuity
                for j = 1:3
                    rightCOP(hsInd-analogSampMult+2:min([hsInd+1 length(r_forces_Nm)]),j) = ... 
                        linspace(rightCOP(hsInd-analogSampMult+2,j),rightCOP(min([hsInd+1 length(r_forces_Nm)]),j),length(hsInd-analogSampMult+2:min([hsInd+1 length(r_forces_Nm)])))' ;
                    rightCOP(max([toInd-1 1]):toInd+analogSampMult,j) = ... 
                        linspace(rightCOP(max([toInd-1 1]),j),rightCOP(toInd+analogSampMult,j),length(max([toInd-1 1]):toInd+analogSampMult))' ;
                end
            end
        
        % Left Foot COP Manipulation
            for i=1:length(l_stepInds)+1
                
                % Deal with the first step
                if i == 1 && l_stepInds(i) == 1 % if foot is on ground to start, go to next swing phase
                    i = i+1 ; 
                    toInd = l_stepInds(1,2) ;
                    hsInd = l_stepInds(2,1) ;
                    halfInd = round(mean([toInd,hsInd])) ;
                elseif i == 1 && l_stepInds(i) > 1 % if swing phase to start, make toe-off index 1
                    toInd = 1 ; 
                    hsInd = l_stepInds(i,1) ;
                    halfInd = 1 ;
                % Deal with the last step
                elseif i == length(l_stepInds)+1 && l_stepInds(i-1,2) == length(forces_Nm) % if foot is on ground to end, repeat last calculation
                    i = i-1 ; 
                    toInd = l_stepInds(end-1,2) ;
                    hsInd = l_stepInds(end,1) ;
                    halfInd = round(mean([hsInd,toInd])) ;
                elseif i == length(l_stepInds)+1 && l_stepInds(i) < length(forces_Nm) % if swing phase at end, make heel-strike last index
                    toInd = l_stepInds(end,2) ;
                    hsInd = length(forces_Nm) ; 
                    halfInd = length(forces_Nm) ; 
                elseif i >1 && i<length(l_stepInds)+1  % steps that aren't beginning or end
                    toInd = l_stepInds(i-1,2) ;        
                    hsInd = l_stepInds(i,1) ;
                    halfInd = round(mean([hsInd,toInd])) ;
                end
                
                % March backwards on toInd and forwards on hsInd until Fz > thresh_COP
                FzSample = leftforces(toInd,2);  % it is the y force in Opensim land
                while toInd>1 && FzSample<thresh_COP
                    toInd = toInd-1 ;
                    FzSample = leftforces(toInd,2) ;
                end
                FzSample = leftforces(hsInd,2) ; % it is the y force in Opensim land
                while hsInd<length(forces_Nm) && FzSample<thresh_COP
                    hsInd = hsInd + 1 ;
                    FzSample = leftforces(hsInd,2) ;
                end
                
                % Plug in Heel COP for heel strike and toe COP for toe-off
                leftCOP(toInd:halfInd,:) = l_toe_proj(toInd:halfInd,:) ; % First half of swing phase COP is at toe
                leftCOP(halfInd:hsInd,:) = l_calc_proj(halfInd:hsInd,:) ; % Second half of swing phase COP is at heel
           
                % Linearly connect junctions to avoid step discontinuity
                for j = 1:3
                    leftCOP(hsInd-analogSampMult+2:min([hsInd+1 length(l_forces_Nm)]),j) = ... 
                        linspace(leftCOP(hsInd-analogSampMult+2,j),leftCOP(min([hsInd+1 length(r_forces_Nm)]),j),length(hsInd-analogSampMult+2:min([hsInd+1 length(l_forces_Nm)])))' ;
                    leftCOP(max([toInd-1 1]):toInd+analogSampMult,j) = ... 
                        linspace(leftCOP(max([toInd-1 1]),j),leftCOP(toInd+analogSampMult,j),length(max([toInd-1 1]):toInd+analogSampMult))' ;
                end
        
            end
                
            % Filter COP transitions at 3x filter frequency (won't affect real signal, but will
            % smooth step discontinuity between swing and stance. It doesn't really
            % matter since F=0.
            % [B_COP,A_COP] = butter(2,filt_freq*3/(samprate_a/2)) ; 
            % leftCOPfilt = filtfilt(B_COP,A_COP,leftCOP) ; 
            % rightCOPfilt = filtfilt(B_COP,A_COP,rightCOP) ;    
        
        else % walking
            disp('processing as treadmill walking.')

            filt_freq = freq_filtering_walk ; % lpCutoffFreq for force and marker data
            thresh_high = 30 ; % N Everything below this goes to 0
            thresh_low = zero_threshold ; % N Everything below this goes to 0 of the filtered version
            threshold = zero_threshold ; % Fz threshold in Newtons - this is how we define steps
            
            % Turning Forces from V to Newtons, Filtering, and Zeroing during swing
            % This structure includes forces and COP for FP1 (right foot) and FP2 (left foot) in the
            % following order: Fx Fy Fz COPx COPy COPz Tz
            forces_Nm = Analog2Force_TM(forceraw,TreadmillCalibMatrix,filt_freq,samp_rate(1),thresh_high,thresh_low) ;
            
            rightforces=forces_Nm(:,1:3);
            leftforces=forces_Nm(:,8:10);
            rightCOP=forces_Nm(:,4:6);
            leftCOP=forces_Nm(:,11:13);
            
            % Right limb
            rightmoments(:,3)=forces_Nm(:,7);
            % Set Mx and My equal to zero because they also act at the center of pressure
            rightmoments(:,1:2)=zeros(size(forces_Nm,1),2);
            
            % Left limb
            leftmoments(:,3)=forces_Nm(:,14);
            % Set Mx and My equal to zero because they also act at the center of pressure
            leftmoments(:,1:2)=zeros(size(forces_Nm,1),2);

            % Transform forces and COP into x-forward, y-up, and z-right for
            % OpenSim
            R=[1  0  0;
                0  0 -1;
                0  1  0];
    
            leftforces=leftforces*R; leftmoments=leftmoments*R; leftCOP=leftCOP*R;
            rightforces=rightforces*R; rightmoments=rightmoments*R; rightCOP=rightCOP*R;      
        end

    % In this case, you are working with an overground trial
    else
        treadmill = false ;
        % Figure out if it is walking or general
        if ~exist('walking')
            answer = questdlg('What type of overground trial is this?', ...
                'OG trial type', ...
                'walking/running (output forces for each leg)','general (output forces for each plate)','walking/running (output forces for each leg)');
            % Handle response
            switch answer
                case 'walking/running (output forces for each leg)'
                    walking = true;
                case 'general (output forces for each plate)'
                    walking = false;
            end
        end
        
        
        forcenames = ['F1X';'F1Y';'F1Z';'M1X';'M1Y';'M1Z';'F2X';'F2Y';'F2Z';'M2X';'M2Y';'M2Z';'F3X';'F3Y';'F3Z';'M3X';'M3Y';'M3Z'] ;
        
        % Create raw matrix of forces
        forceraw = zeros(size(data,1),length(forcenames)) ;
        for p = 1:size(forcenames,1) ;
            forceindicies(p) = find(strcmp(channel_names,forcenames(p,:))) ;
            forceraw(:,p) = data(:,forceindicies(p)) ;
        end
        
        filt_freq = freq_filtering ; % lpCutoffFreq for force and marker data
        threshold = zero_threshold ; % Fz threshold in Newtons - this is how we define steps
        
        % Turning Forces from V to Newtons, Filtering, and Zeroing during swing
        % This structure includes forces and COP for FP1 (right foot) and FP2 (left foot) in the
        % following order: Fx Fy Fz COPx COPy COPz Tz
        [forces_proc_meters] = Analog2Force_OG(forceraw,threshold,filt_freq,samp_rate(1)) ;
        
        if walking
            infile=strrep(infile,'.anc','.trc');
            [pos,time,f,n,nmrk,mrk_names,file,inpath]=load_trc(infile,inpath);

            RFoot=find(strcmp(mrk_names,'r_calc')==1);
            RFoot=pos(:,RFoot*3-2:RFoot*3)/1000;

            LFoot=find(strcmp(mrk_names,'L_calc')==1);
            LFoot=pos(:,LFoot*3-2:LFoot*3)/1000;

            % downsample forces to compare with motion data
            match_forces=downsample(forces_proc_meters,20);
            match_forces=match_forces(1:length(LFoot),:);

            leftforces=zeros(length(forces_proc_meters),3); leftmoments=zeros(length(forces_proc_meters),3); leftCOP=zeros(length(forces_proc_meters),3);  
            rightforces=zeros(length(forces_proc_meters),3); rightmoments=zeros(length(forces_proc_meters),3); rightCOP=zeros(length(forces_proc_meters),3);
            % Distance from left and right feet to COPy, only during foot contact
            ii=find(match_forces(:,5)>0);
            FPdistL=mean(sqrt((match_forces(ii,5)-LFoot(ii,2)).^2));
            FPdistR=mean(sqrt((match_forces(ii,5)-RFoot(ii,2)).^2));
            if FPdistL<FPdistR
                FootContact(1)='L';
                leftforces=leftforces+forces_proc_meters(:,1:3);
                leftmoments(:,3)=leftmoments(:,3)+forces_proc_meters(:,7);
                leftCOP=leftCOP+forces_proc_meters(:,4:6);
            else
                FootContact(1)='R';
                rightforces=rightforces+forces_proc_meters(:,1:3);
                rightmoments(:,3)=rightmoments(:,3)+forces_proc_meters(:,7);
                rightCOP=rightCOP+forces_proc_meters(:,4:6);
            end

            ii=find(match_forces(:,12)>0);
            FPdistL=mean(sqrt((match_forces(ii,12)-LFoot(ii,2)).^2));
            FPdistR=mean(sqrt((match_forces(ii,12)-RFoot(ii,2)).^2));
            if FPdistL<FPdistR
                FootContact(2)='L';
                leftforces=leftforces+forces_proc_meters(:,8:10);
                leftmoments(:,3)=leftmoments(:,3)+forces_proc_meters(:,14);
                leftCOP=leftCOP+forces_proc_meters(:,11:13);
            else
                FootContact(2)='R';
                rightforces=rightforces+forces_proc_meters(:,8:10);
                rightmoments(:,3)=rightmoments(:,3)+forces_proc_meters(:,14);
                rightCOP=rightCOP+forces_proc_meters(:,11:13);
            end

            ii=find(match_forces(:,19)>0);
            FPdistL=mean(sqrt((match_forces(ii,19)-LFoot(ii,2)).^2));
            FPdistR=mean(sqrt((match_forces(ii,19)-RFoot(ii,2)).^2));
            if FPdistL<FPdistR
                FootContact(3)='L';
                leftforces=leftforces+forces_proc_meters(:,15:17);
                leftmoments(:,3)=leftmoments(:,3)+forces_proc_meters(:,21);
                leftCOP=leftCOP+forces_proc_meters(:,18:20);
            else
                FootContact(3)='R';
                rightforces=rightforces+forces_proc_meters(:,15:17);
                rightmoments(:,3)=rightmoments(:,3)+forces_proc_meters(:,21);
                rightCOP=rightCOP+forces_proc_meters(:,18:20);
            end

       
            % Transform forces and COP into x-forward, y-up, and z-right for
            % OpenSim
            R=[1  0  0;
                0  0 -1;
                0  1  0];

            leftforces=leftforces*R; leftmoments=leftmoments*R; leftCOP=leftCOP*R;
            rightforces=rightforces*R; rightmoments=rightmoments*R; rightCOP=rightCOP*R;

            % Linear interpolation on COP to remove sharp on/off square-wave type
            % cut-offs between foot = on ground, and foot = in air
            t = 3; % offset for interpolating
            ii=find(rightCOP(:,1)>0,1); 
            rightCOP(1:ii+t,1)=rightCOP(ii+t,1); % x-direction (forward)
            rightCOP(1:ii+t,3)=rightCOP(ii+t,3); % z-direction (sideways)

            jj=1; kk=1:length(rightCOP); 
            while jj<length(rightCOP)
                jj=find(rightCOP(ii+10:length(rightCOP),1)==0,1)+ii+10; % start interpolation
                ii=find(rightCOP(jj+10:length(rightCOP),1)>0,1)+jj+10; % end interpolation
                if isempty(ii) % if empty, then go until the end of the trial
                    rightCOP(jj-t:length(rightCOP),1)=rightCOP(jj-t,1);
                    rightCOP(jj-t:length(rightCOP),3)=rightCOP(jj-t,3);
                else 
                    rightCOP(jj-t:ii,1)=interp1([kk(jj-t) kk(ii)],[rightCOP(jj-t,1) rightCOP(ii,1)],kk(jj-t):kk(ii));
                    rightCOP(jj-t:ii,3)=interp1([kk(jj-t) kk(ii)],[rightCOP(jj-t,3) rightCOP(ii,3)],kk(jj-t):kk(ii));
                end
                jj=find(rightCOP(ii+10:length(rightCOP),1)>0,1)+ii+10;
                if isempty(ii), break, end
            end

            ii=find(leftCOP(:,1)>0,1);
            leftCOP(1:ii+t,1)=leftCOP(ii+t,1);
            leftCOP(1:ii+t,3)=leftCOP(ii+t,3);

            jj=1; kk=1:length(leftCOP); 
            while jj<length(leftCOP)
                jj=find(leftCOP(ii+10:length(leftCOP),1)==0,1)+ii+10;
                ii=find(leftCOP(jj+10:length(leftCOP),1)>0,1)+jj+10;
                if isempty(ii)
                    leftCOP(jj-t:length(leftCOP),1)=leftCOP(jj-t,1);
                    leftCOP(jj-t:length(leftCOP),3)=leftCOP(jj-t,3);
                else
                    leftCOP(jj-t:ii,1)=interp1([kk(jj-t) kk(ii)],[leftCOP(jj-t,1) leftCOP(ii,1)],kk(jj-t):kk(ii));
                    leftCOP(jj-t:ii,3)=interp1([kk(jj-t) kk(ii)],[leftCOP(jj-t,3) leftCOP(ii,3)],kk(jj-t):kk(ii));
                end
                jj=find(leftCOP(ii+10:length(leftCOP),1)>0,1)+ii+10;
                if isempty(ii), break, end
            end
            
            
        else % for general OG trials - output by forceplate number
            % Transform forces and COP into x-forward, y-up, and z-right for
            % OpenSim
            R=[1  0  0;
                0  0 -1;
                0  1  0];

            if rotateOG_xForward
                R = R* [0 0 -1;
                        0 1 0;
                        1 0 0] ;
            end

            R9 = zeros(9,9) ; R9(1:3,1:3) = R ; R9(4:6,4:6) = R ; R9(7:9,7:9) = R ;
            R27 = blkdiag(R9,R9,R9) ;
            
            % Get into F,COP,M order (add zeros for the Mx and My entries)
            zeroCols = zeros(size(forces_proc_meters,1),2) ;
            forces_proc_meters = horzcat(forces_proc_meters(:,1:6),zeroCols,...
                                         forces_proc_meters(:,7:13),zeroCols,...
                                         forces_proc_meters(:,14:20),zeroCols,...
                                         forces_proc_meters(:,21)) ;
            
            % Rotate into Opensim frame
            GRF_write = forces_proc_meters * R27 ;
            
        end % walking
        
    end % overground
    
    
%% Write forces files

    if walking || treadmill % write out a per-foot Grf file
        % Write Forces File
        npts = length(rightforces);

        input_file = strrep(infile, '.trc', ['_forces_filt' num2str(freq_filtering_walk) 'Hz.mot']);

        fid = fopen([inpath,input_file],'w');

        % Write the header
                colNames = {'time'} ;
        nPlates = 2 ;
        dTypes = {'ground_force_v','ground_force_p','ground_torque_'} ;
        dims = {'x','y','z'} ;
        for iPlate = 1:nPlates
            for j = 1:length(dTypes)
                for k = 1:length(dims) ;
                    colNames{end+1} = [plateNamesWalking{iPlate} '_' dTypes{j} dims{k}] ;
                end
            end
        end
           
        fprintf(fid,'%s\n',input_file);
        fprintf(fid,'%s\n','version=1');
        fprintf(fid,'%s\n',['nRows=' num2str(size(rightforces,1))]);
        fprintf(fid,'%s\n',['nColumns=',num2str(9*nPlates+1)]);
        fprintf(fid,'%s\n','inDegrees=yes');
        fprintf(fid,'%s\n','endheader');
        fprintf(fid,repmat('%s\t',1,9*nPlates+1),colNames{:});
        fprintf(fid,'\n') ;
        % Write the data
        newdata=[rightforces rightCOP rightmoments leftforces leftCOP leftmoments];
        for j=1:npts
            % New file order is RFx, RFy, RFz, RCOPx, RCOPy, RCOPz, LFx, LFy, LFz, LCOPx, LCOPy, LCOPz, RMx, RMy, RMz, LMx, LMy, LMz
            fprintf(fid,'%f',time_forces(j));
            fprintf(fid,'\t%10.6f',newdata(j,:));
            fprintf(fid,'\n');
        end

        disp(['Wrote ',num2str(npts),' frames of force data to ',input_file]);
        fclose(fid);
        
    else% write out a per-plate Grf file
        % Write Forces File
        npts = size(GRF_write,1);

        input_file = strrep(infile, '.anc', ['_forces_filt' num2str(freq_filtering) 'Hz.mot']);

        fid = fopen([tempdir,input_file],'w');
        
        colNames = {'time'} ;
        nPlates = 3 ;
        dTypes = {'ground_force_v','ground_force_p','ground_torque_'} ;
        dims = {'x','y','z'} ;
        for iPlate = 1:nPlates
            for j = 1:length(dTypes)
                for k = 1:length(dims) ;
                    colNames{end+1} = [plateNamesOG{iPlate} '_' dTypes{j} dims{k}] ;
                end
            end
        end
           
        % Write the header
        fprintf(fid,'%s\n',input_file);
        fprintf(fid,'%s\n','version=1');
        fprintf(fid,'%s\n',['nRows=' num2str(length(GRF_write))]);
        fprintf(fid,'%s\n',['nColumns=',num2str(9*nPlates+1)]);
        fprintf(fid,'%s\n','inDegrees=yes');
        fprintf(fid,'%s\n','endheader');
        fprintf(fid,repmat('%s\t',1,9*nPlates+1),colNames{:});
        fprintf(fid,'\n') ;
        
        % Write the data
        for j=1:npts
            % Data order is 1Fxyz,1COPxyz,1Mxyz,2Fxyz...
            fprintf(fid,'%f',time_forces(j));
            fprintf(fid,'\t%10.6f',GRF_write(j,:));
            fprintf(fid,'\n');
        end

        disp(['Wrote ',num2str(npts),' frames of force data to ',input_file]);
        fclose(fid);
        copyfile([tempdir,input_file],[inpath,input_file])
        delete([tempdir,input_file])
        
    end
end