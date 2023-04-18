% ---Function 'Edf2Mat_UCH'---
% 
% Convert .edf file to .mat file 
% Uses Edf2Mat Matlab toolbox found at github.com/mzhuang666/edf-converter
%      NOTE: Need to have this toolbox downloaded and on path 
%
% Inputs: 1) file to convert 2) Patient ID, 3) block (learning 'L' or recog 'R'), 
% 4) variant ('1', '2', or '3') 
%
% Output: File saved with patient ID, block type, and date of recording
%
% Example function call: Edf2Mat_UCH('NO20221615110.edf', 'MW9', 'L' , '1')
%
% Initial version: May 11 2022
% Update 1: July 27 2022
% Update 2: August 2 2022
%
%
% Marielle L. Darwin & John A. Thompson 

function [eyeProcName] = Edf2Mat_UCH(edfFile, patientID, block, variant, fileDIR, saveDIR)
% edfFile = 'NO20221615110.edf';
% patientID = 'MW9';
% block = 'L';
% variant = 1
% fileDIR = directory location ////// OPTIONAL!!

if nargin < 5
    eyeDataDir = 1;
else
    eyeDataDir = 2;
end

% Select folder for edf-converter
if ~exist('Edf2Mat.m','file')
    uiwait(msgbox('Navigate to and select edf-converter folder'))
    edfLoc = uigetdir();
    addpath(genpath(edfLoc));
end

paths = [];
% Set path structure
switch eyeDataDir
    case 1
        uiwait(msgbox('Navigate to and select folder that contains .edf file'))
        %e.g. 'C:\Users\darwinm\Documents\Thompson Lab\Microwire\PatientData\MW9\'
        paths.basePath = uigetdir;
        paths.savePath = paths.basePath;
    case 2
        paths.basePath = fileDIR;
        paths.savePath = saveDIR;
end
paths.path_edf = [strcat(paths.basePath,'\',edfFile)];
cd(paths.basePath);

% Construct new file name
eyeSp = split(edfFile,'.');
eyeRM = extractAfter(eyeSp(1),'NO');
filename = [strcat('eyetrack_', patientID, '_', variant, '_', block, '_', eyeRM{1}, '.mat')];

% Convert chosen .edf file to .mat file and save
edfRAW = Edf2Mat(paths.path_edf);
cd(paths.savePath)
save(filename,'edfRAW');
eyeProcName = filename;
end