%% For writing EMG to *.sto file for state tracking in CMC
clear all; close all; format compact; clc ; warning off ;

osimMusclePrefix = {'vasmed_l','vaslat_l', 'tibant_l', 'recfem_l', 'addbrev_l', 'bflh_l', 'bfsh_l', 'gaslat_l', 'gasmed_l', 'soleus_l'}; %  
muscleNames = {'VM', 'VL', 'TA', 'RF', 'ADD', 'BF', 'ST', 'LG', 'MG', 'SOL'}; % Contralateral needed if implemented in collection  'VL_cont', 'BF_cont', 'MG(MedGas)_cont', 'SOL_cont'
           
averageMuscles = false ;
% musclesToAverage = {'MG','LG'} ; % 2xnpairs EMG labels of muscles to be weighted averaged based on max isometric force in model
musclesToAverage = {} ; % 2xnpairs EMG labels of muscles to be weighted averaged based on max isometric force in model

repoDir = pwd
subjectBaseDir = [repoDir, '\Data\treadmill\'] ;
writeBaseDir = subjectBaseDir ;
commonCodeDir = [repoDir, '\common'] ;

modelFilePath = [commonCodeDir, '\Rajagopal2015_passiveCal_hipAbdMoved.osim'] ;

subjects = [1] ; 
% 
% osimMusclePrefix = {'soleus','gasmed','gaslat','vasmed','vaslat','recfem','vasint'} ; 
% muscleNames = {'SOL','MG','LG','VM','VL','RF','VL'} ;
% averageMuscles = false ;
% musclesToAverage = {} ; % 2xnpairs EMG labels of muscles to be weighted averaged based on max isometric force in model
% 
% subjectBaseDir = 'W:\OA_GaitRetraining\GastrocAvoidance\DATA\' ;
% commoncodeDir = 'W:\OA_GaitRetraining\Matlab\common' ;
% modelFilePath = 'W:\OA_GaitRetraining\GastrocAvoidance\OpenSim\Models\ArmlessRajagopal_40.osim' ;
% 
% subjects = [1] ;
% % filenames = {'walking_baseline1'} ;

FILT.EMGfiltFreq_BP = [30 500] ;
FILT.EMGfiltFreq_LP = 6 ;
t_d = 0; % electromechanical delay time from Arnold et al. 2013 was 0.04s


addpath(genpath(commonCodeDir)) ;

for sub = 1:length(subjects)
    subject = subjects(sub) ;
    subjectdir = [subjectBaseDir 'Subject' num2str(subject) '\'] ; %sprintf('%2d',subject) can be adjusted for automatic subject change
    
    dirStuff = dir([subjectdir 'Edited\*.anc']) ;
    filenames = {dirStuff(:).name} ;
    
    % get Marker sample rate
    dirStuff = dir([subjectdir 'Edited\*.trc']) ;
    filename = dirStuff(1).name ;
    [header, data] = TRCload([subjectdir 'Edited\' filename]) ;
    mkrSampleRate = header.samplerate ;
     
for fnum = 1:length(filenames)
    % Process Max Activation trials
    if fnum == 1
    maxFnames = dir([subjectdir 'Edited\maxAct*.anc']) ;    
    maxFileNames = {maxFnames(:).name} ;    
    for i = 1:length(maxFileNames)
        pathnamesMaxAct{i} = [subjectdir 'Edited\' maxFileNames{i}] ;
    end
    NORM = processMaxEMGTrials(FILT,muscleNames,pathnamesMaxAct) ;
    disp('Max Activation Trials Processed')
    end
    
    % Load dynamic trial
    filename = filenames{fnum}(1:end-4) ;
           
    [header data] = ANCload([subjectdir 'Edited\' filename '.anc']) ;
    time = data(:,1) ;
    
    % 16-bit system 2^16 = 65536
    % range is given in milivolts, so multiply by 0.001 to make volts
    data=(ones(size(data,1),1)*header.ranges*2).*(data/65536)*0.001; % Convert all data into volts
    
    for i = 1:length(muscleNames)
        EMGcols(i) = strmatch(muscleNames{i},header.varnames, 'exact') ;
    end
    samprate_a = header.samprates(EMGcols(1)) ;
    
    EMGraw = data(:,EMGcols) ; 
    
    EMGproc = postprocessEMGwholetrial(EMGraw,FILT,samprate_a) ;
    EMGnorm = EMGproc./(ones(length(EMGproc),1)*NORM.maxAct) ;
    
    % time shift holding first value
    
    [~,ind] = min(abs(time-t_d)) ;% index of starting number
    EMGshift = [repmat(EMGnorm(1,:),ind-1,1); EMGnorm(1:end-ind+1,:)] ;
    
    % downsample EMG to marker rate
    EMGdownsamp = downsample(EMGshift,samprate_a/mkrSampleRate) ;
    timedownsamp = downsample(time,samprate_a/mkrSampleRate) ;
    
    % If muscles are to be averaged. Like the gastrocs.
    if averageMuscles
        EMGdownsamp_old = EMGdownsamp ;
        import org.opensim.modeling.*
        osimModel = Model(modelFilePath);
        muscles = osimModel.updMuscles() ;
        for i = 1:size(musclesToAverage,1) ;
            m1_ind = strmatch(musclesToAverage(i,1),muscleNames) ;
            m2_ind = strmatch(musclesToAverage(i,2),muscleNames) ;
            m1_osimName = [osimMusclePrefix{m1_ind}] ;
            m2_osimName = [osimMusclePrefix{m2_ind}] ;
            m1_Force = muscles.get(m1_osimName).get_max_isometric_force ;
            m2_Force = muscles.get(m2_osimName).get_max_isometric_force ;
            
            newEMG = (m1_Force*EMGdownsamp(:,m1_ind)+m2_Force*EMGdownsamp(:,m2_ind))/ ...
                (m1_Force+m2_Force) ; % Weighted average of EMG signals based on max isometric force
            EMGdownsamp(:,[m1_ind m2_ind]) = repmat(newEMG,1,2) ; % Set both equal
        end
    end
        
    osimMuscNames = cellfun(@(c)[c '_activation'],osimMusclePrefix,'uni',false) ;
    headerSTO = [{'time'},osimMuscNames] ;
    writeDir = [writeBaseDir 'Subject' num2str(subject) '/'] ;
    writeDirSTO = [writeDir '/EMGData/'] ;
    try ; mkdir(writeDirSTO) ; end
    filenameSTO = [filename '_EMG'] ;

    % plot gastrocnemius and soleus activation for quick comparison
    if fnum == 12
        fig = figure(1);
%         subplot (3, 3, fnum-11)
        plot(EMGdownsamp(:, 8));
        hold on
        plot(EMGdownsamp(:, 9));
        plot(EMGdownsamp(:, 10));
        title(filenames(fnum));
        
%         han=axes(fig,'visible','off');
%         % legend({'Line 1','Line 2','Line 3'},'FontSize',12,'Location', 'east');
%         han.XLabel.Visible='on';
%         han.YLabel.Visible='on';
%         % han.Legend.TextColor = 'black';
%         ylabel(han,'EMG Activation');
%         xlabel(han,'time');
    end
    
    
    % write to .sto file
    writeSTO([timedownsamp EMGdownsamp],headerSTO,writeDirSTO,filenameSTO) ;
    
end %fnum
end %sub
    

