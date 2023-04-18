%%
% STEP 1: Put EDF files into a folder with patient ID 
    % Path example: C:\Users\darwinm\Documents\MATLAB\EyeTrack\eyeTrack\AMC_PY21NO05

% STEP 2: Update variantLIST excel sheet with new patient
    % Path example: C:\Users\darwinm\Documents\MATLAB\EyeTrack\variantLIST

% STEP 3: Change behavDataLOC and behavFILE to be specific to pt and pt session

% STEP 4: Run Initial_EyeAnalysis_MLD_v4.m f(x)

userPC = 'MLD';
switch userPC
    case 'JAT'
        excelLOC = 'C:\Users\Admin\Documents\Github\Eye-tracking';
        mainLOC = 'E:\Dropbox\SfN_2022\dataOut_AMC\dataOut_AMC\eyeTrack';
        saveLOC = [mainLOC, '\eyeDATA'];
        cleanedDataLOC = [saveLOC, '\cleaned_eyeDATA'];
        %behavDataLOC = 
    case 'MLD'
         basePath = 'C:\Users\darwinm\Documents\MATLAB';
         excelLOC = [basePath, '\EyeTrack'];
         mainLOC = [excelLOC, '\eyeTrack'];
         saveLOC = [mainLOC, '\eyeDATA'];
         cleanedDataLOC = [saveLOC, '\cleaned_eyeDATA'];
end

% Set patient ID and files for that patient
behavDataLOC = 'C:\Users\darwinm\Documents\Thompson Lab\Microwire\PatientData\MW5';
behavFILE = 'recog_7.16.21_MW5.mat';
eyeData_pt = 'eyeData_AMC_PY21NO05';

%%
% Run Initial_EyeAnalysis function
addpath(genpath(excelLOC));
Initial_EyeAnalysis_MLD_v4(excelLOC, mainLOC, behavDataLOC, behavFILE, saveLOC)

%%
% STEP 4: Run eyeTRACKproc.m f(x)  
eyeTRACKproc(cleanedDataLOC, saveLOC, eyeData_pt);

%% 
% STEP 5: Figures - line plot of pupil diameter over time

%% Questions / notes
% 1. before I loop through all patients, do I need a container for all data/ won't overwrite?
%   -might not need to loop through?
%   -at end, single output for each patient that is everything i need for analyses: could be variantS
%       -mat file with 3 variables that are read into workspace when loaded file: 1) variantS, 2) pt ID & 3) date created (datetime f(x))
dateModified = datetime;
patientID = 'MW9';
save('finalEyeData_ptMW9.mat', 'patientID', 'dateModified','variantS');
% 
% 
% 
% 

% 2. adding in confidence rating bins to variantS
% 3. trimming lengths to be equal for some patients
% 
%    
% 
% 
%  
%    

