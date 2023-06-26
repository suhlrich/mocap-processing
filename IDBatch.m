% ----------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and           %
% simulation. See http://opensim.stanford.edu and the NOTICE file         %
% for more information. OpenSim is developed at Stanford University       %
% and supported by the US National Institutes of Health (U54 GM072970,    %
% R24 HD065690) and by DARPA through the Warrior Web program.             %
%                                                                         %   
% Copyright (c) 2005-2012 Stanford University and the Authors             %
% Author(s): Edith Arnold                                                 %  
%                                                                         %   
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

% setupAndRunIKBatchExample.m                                                 
% Author: Edith Arnold

% This example script runs multiple inverse kinematics trials for the model Subject01. 
% All input files are in the folder ../Matlab/testData/Subject01
% To see the results load the model and ik output in the GUI.
clc; clear

% pause(1*60*60)

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

subjects = [1] ;
basedir = 'W:\OA_GaitRetraining\GastrocAvoidance\DATA\' ;
modelName = 'ArmlessRajagopal_40_abdChg_passiveCalib_KneesMoved_scaled.osim' ;
genericIKSettingsFileName = 'W:\OA_GaitRetraining\GastrocAvoidance\OpenSim\Setup_ID_generic.xml' ;
genericExternalLoadsFileName = 'W:\OA_GaitRetraining\GastrocAvoidance\OpenSim\ExternalLoads_generic.xml' ;
IKfiltFreq = 6 ; % original trials at 6Hz

addpath(genpath('\common\')) ;

for sub = 1:length(subjects)
    subject = subjects(sub) ;
    disp(['Analyzing Subject ' num2str(subject)])

    % move to directory where this subject's files are kept
    % subjectdir = uigetdir('W:\OA_GaitRetraining\GastrocAvoidance\DATA\', 'Select the folder that contains the current subject data');
    subjectdir = [basedir 'Subject' num2str(subject) '\'] ;

    % Go to the folder in the subject's folder where .trc files are
    trc_data_folder = [subjectdir 'Edited\Files_W_HJCs\'] ;
    names = dir(fullfile(trc_data_folder, 'walking_*.trc')) ;
    trialsForID = {names(:).name} ;
    nTrials = length(trialsForID);
    
    % Folder with GRF files
    GRF_data_folder = [subjectdir 'Edited\'] ;

    % Folder with IK files
    coord_data_folder = [subjectdir 'OpenSim\IK\KneesMoved\'] ;
    
    % specify where results will be printed.
    results_folder_base = ([subjectdir 'OpenSim\ID\KneesMoved6Hz\']);

    % Loop through the trials
    for trial= 1:nTrials;
        
        % Get and operate on the files
        % Choose a generic setup file to work from
        idTool = InverseDynamicsTool([genericIKSettingsFileName]);
        % Get the model
        % Load the model and initialize
        model = Model([subjectdir 'OpenSim\Models\' modelName]);
        model.initSystem();
        
        % Tell Tool to use the loaded model
        idTool.setModelFileName([subjectdir 'OpenSim\Models\' modelName]);
        idTool.setModel(model);

        % Get the name of the file for this trial
        markerFile = trialsForID{trial};

        % Create name of trial from .trc file name
        name = markerFile(1:end-4) ;
        fullpath = [trc_data_folder markerFile] ;
        
        % Set Results Folder
        results_folder = [results_folder_base name '\'] ;
                
        % Get trc data to determine time range
        markerData = MarkerData(fullpath);

        % Get initial and final time 
        initial_time = markerData.getStartFrameTime();
        final_time = markerData.getLastFrameTime();
        
        % Write ExternalLoads file
        thisExternalLoads = ExternalLoads(genericExternalLoadsFileName,true);
        thisExternalLoads.setDataFileName(char([GRF_data_folder name '_forces.mot'])) ;
        thisExternalLoads.setExternalLoadsModelKinematicsFileName(char([coord_data_folder name '\output\results_ik.sto']));
        thisExternalLoads.print([results_folder '\externalLoads_' name '.xml']) ;        

        
        % Setup the idTool for this trial
        idTool.setName(name);
        % idTool.setMarkerDataFileName(fullpath);
        idTool.setStartTime(initial_time);
        idTool.setEndTime(final_time);
        idTool.setCoordinatesFileName([coord_data_folder name '\output\results_ik.sto']);
        idTool.setExternalLoadsFileName([results_folder 'externalLoads_' name '.xml']);
        idTool.setOutputGenForceFileName('results_id.sto');
        idTool.setResultsDir([results_folder 'output\']);
        idTool.setLowpassCutoffFrequency(IKfiltFreq) ;
    
        % Save the settings in a setup file
        outfile = ['Setup_ID_' name '.xml'];
        idTool.print([results_folder '\' outfile]);
        
        fprintf(['Performing ID on cycle # ' num2str(trial) ' ' name '\n']);
        % Run ID
        idTool.run();

        clear idTool;
    end
end