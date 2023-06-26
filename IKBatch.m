
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

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

subjects = [1:10] ;
basedir = 'W:\OA_GaitRetraining\GastrocAvoidance\DATA\' ;
modelName = 'ArmlessRajagopal_40_abdChg_passiveCalib_KneesMoved_scaled.osim' ;
batchIKSettingsFileName = 'W:\OA_GaitRetraining\GastrocAvoidance\OpenSim\Setup_IK_generic.xml' ;

for sub = 1:length(subjects)
    subject = subjects(sub) ;
    disp(['Analyzing Subject ' num2str(subject)])

    % move to directory where this subject's files are kept
    % subjectdir = uigetdir('W:\OA_GaitRetraining\GastrocAvoidance\DATA\', 'Select the folder that contains the current subject data');
    subjectdir = [basedir 'Subject' num2str(subject) '\'] ;

    % Go to the folder in the subject's folder where .trc files are
    trc_data_folder = [subjectdir '\Edited\Files_W_HJCs\'] ;
    names = dir(fullfile(trc_data_folder, 'walking_*.trc')) ;
    trialsForIK = {names(:).name} ;
    nTrials = length(trialsForIK);
    
    % specify where results will be printed.
    results_folder = ([subjectdir 'OpenSim\IK\KneesMoved\']);

    % Get and operate on the files
    % Choose a generic setup file to work from
    ikTool = InverseKinematicsTool(batchIKSettingsFileName);
    % Get the model
    % Load the model and initialize
    model = Model([subjectdir 'OpenSim\Models\' modelName]);
    model.initSystem();

    % Tell Tool to use the loaded model
    ikTool.setModel(model);

    % Loop through the trials
    for trial= 1:nTrials;

        %Generic setup file to work from
        %ikTool = InverseKinematicsTool(['S:\Human Performance Lab\MotionAnalysis\OpenSim Models and Files\Generic_ACL_IKSetup_report_markers.xml']);
        %model = Model([modelFilePath modelFile]);
        %model.initSystem();
        %ikTool.setModel(model);

        % Get the name of the file for this trial
        markerFile = trialsForIK{trial};

        % Create name of trial from .trc file name
        name = markerFile(1:end-4) ;
        fullpath = [trc_data_folder markerFile] ;

        % Get trc data to determine time range
        markerData = MarkerData(fullpath);

        % Get initial and final time 
        initial_time = markerData.getStartFrameTime();
        final_time = markerData.getLastFrameTime();

        % Setup the ikTool for this trial
        ikTool.setName(name);
        ikTool.setMarkerDataFileName(fullpath);
        ikTool.setStartTime(initial_time);
        ikTool.setEndTime(final_time);
        ikTool.setOutputMotionFileName([results_folder name '\output\results_ik.sto']);
        ikTool.setResultsDir([results_folder name '\output\']);

        % Save the settings in a setup file
        outfile = ['Setup_IK_' name '.xml'];
        try
            ikTool.print([results_folder name '\' outfile]);
        catch
            mkdir([results_folder name])
            ikTool.print([results_folder name '\' outfile]);
        end
        warning off
        mkdir([results_folder name '\output\'])
        warning on

        fprintf(['Performing IK on ' name '\n']);
        % Run IK
         ikTool.run();

        %Give unique name to marker location .sto file (if set to 'true' in
        %setup file)
%         movefile([name '_ik_model_marker_locations.sto'],[results_folder name '\output\ik_model_marker_locations.sto'])
%         movefile([name '_ik_marker_errors.sto'],[results_folder name '\output\ik_model_marker_errors.sto'])

        %clear ikTool;

    end
end