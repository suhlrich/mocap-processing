# mocap-processing
 Process mocap data from the Stanford HPL

Steps from Cortex to simulation:
1) Edit marker data, trim capture with options, save as a "Trimmed_myTrial1.cap". (leaving the number at the end of a new trial name is important.
2) After editing all marker data for a collection, run "GenerateANC_TRC_SDU.sky" in Cortex. Tools->SkyFiles->Batch. If it is not there, take the file from the Cortex/Sky folder in this repository and put in 'C:\ProgramData\Motion Analysis\Cortex6\UserFiles\SkyFiles\Batch'. Replace with your cortex version. You may have to type C:\ProgramData into the file path line in Explorer...it often doesn't show up. This writes out:
    - a .trc file: marker positions
    - a .anc file: analog data in bits. Need to turn this into volts before EMG or force processing.
4) Write GRFs + COP to a .mot file: Run write_GRF_MotFile.m. Change flags depending on treadmill or overground, and how you want to name the forces being applied to both feet. This script takes a .trc and a .anc. It uses .trc to determine what foot to apply forces to and to make sure the COP stays within the foot when vertical forces are low.
5) Add virtual markers, hip centers to marker data, and rotate to OpenSim frame (x forward, y up, z right) from lab frame (x forward, y left, z up when facing cupboards for overground and walking forward on treadmill). This assumes you did dynamic hip joint center trials. If you want to just rotate the data to opensim frame, use RotateTRC.m.
6) Process EMG data and write to a .sto file. This takes in a .anc file, an opensim model, and it looks for normalization .anc files (maxAct_<something>.anc). You define a mapping between your analog muscle names and the muscle names in the opensim model. It then processes the EMG data (bandpass filter, rectify, lowpass filter), normalizes by the largest value it got in any of the maxAct trials, then writes it to a .sto file.
