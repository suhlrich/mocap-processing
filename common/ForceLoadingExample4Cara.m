clear; close all; format compact; 

subjectdir = 'C:\Users\scott.uhlrich\Documents\DelpResearch\HOBL\EMG_pilot\Edited';

% Load file(s) to be converted.
display('Select *.anc files to convert into motion files.');
[files,inpath]=uigetfile('*.anc','Select analog files with forces','multiselect','on',subjectdir);
files=cellstr(files);
cd(inpath)

[a b] = size(files);
for i=1:b;
    clear FPData
    infile=char(files(:,i));
    [samp_rate, channel_names, range, time, data, inpath, fileroot]=open_anc(inpath,infile);
    time_forces=[0; time(1:size(time,1)-1)];
    
    % 16-bit system 2^16 = 65536
    % range is given in milivolts, so multiply by 0.001 to make volts
    data=(ones(size(data,1),1)*range*2).*(data/65536)*0.001; % Convert all data into volts
        
    infile=strrep(infile,'.anc','.trc');
    forcenames = ['F1X';'F1Y';'F1Z';'M1X';'M1Y';'M1Z';'F2X';'F2Y';'F2Z';'M2X';'M2Y';'M2Z'] ;
    load TreadmillCalibMatrix.mat

    % Create raw matrix of forces
    forceraw = zeros(size(data,1),length(forcenames)) ;
    for p = 1:size(forcenames,1) ;
        forceindicies(p) = find(strcmp(channel_names,forcenames(p,:))) ;
        forceraw(:,p) = data(:,forceindicies(p)) ;
    end

    filt_freq = 50 ; % lpCutoffFreq for force and marker data
    numtrials = 20 ; % number of trials for averaging
    thresh_high = 100 ; % N Everything below this goes to 0
    thresh_low = 10 ; % N Everything below this goes to 0 of the filtered version
    threshold = 30 ; % Fz threshold in Newtons - this is how we define steps

    % Turning Forces from V to Newtons, Filtering, and Zeroing during swing
    % This structure includes forces and COP in the
    % following order: Fx Fy Fz COPx COPy COPz Tz (in lab frame x forward,
    % y left, z up)

    forces_Nm = Analog2Force_TMrunning(forceraw,TreadmillCalibMatrix,filt_freq,samp_rate(1),thresh_high,thresh_low) ;
    
    % % % % % % % % % % % % % % % % % % % %
    % % You have beautifully zeroed, filtered forces now. Go do something
    % important with them!
    % % % % % % % % % % %% % % 
end