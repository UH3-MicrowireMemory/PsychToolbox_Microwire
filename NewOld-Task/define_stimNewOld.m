% ---script 'define_stimNewOld'---
% 
% Extract data from Ueli's RecogMemory_MTL_release_v2\Code\dataRelease\stimFiles
%
% \NewOldDelay*_v3.mat: stimuli present in new and old for each variant
% \newOldDelayStimuli*.mat: paths of images for each variant
% 
% Combines all relevant data and saves as 'newOld_stimID_all.mat' with struct 'stimAll'
% 
% Marielle L. Darwin & John A. Thompson | 12.13.2022


% Extract relevant data from all 3 structs & input into one array 
% variant 1
load ('NewOldDelay_v3.mat');
stimLearn_var1 = (experimentStimuli(1).stimuliLearn)';
stimRecog_var1 = (experimentStimuli(2).stimuliRecog)';
stimNewOld_var1 = (experimentStimuli(2).newOldRecog)';

% variant 2
load ('NewOldDelay2_v3.mat');
stimLearn_var2 = (experimentStimuli2(1).stimuliLearn)';
stimRecog_var2 = (experimentStimuli2(2).stimuliRecog)';
stimNewOld_var2 = (experimentStimuli2(2).newOldRecog)';

% variant 3
load ('NewOldDelay3_v3.mat');
stimLearn_var3 = (experimentStimuli3(1).stimuliLearn)';
stimRecog_var3 = (experimentStimuli3(2).stimuliRecog)';
stimNewOld_var3 = (experimentStimuli3(2).newOldRecog)';

% Extract info from 'newOldDelayStimuli*.mat'
imgPath = cell(100,3);
for vi = 1:3
    varNum = eval(['stimLearn_var', num2str(vi)]);
    pathNum = eval(['fileMapping_var', num2str(vi)]);
    for i = 1:length(varNum)
    imgPath{i, vi} = pathNum{varNum(i)};    
    end
end

% Combine into a table and label columns
stimAll = table(stimLearn_var1, stimRecog_var1, stimNewOld_var1, imgPath(:,1),...
    stimLearn_var2, stimRecog_var2, stimNewOld_var2, imgPath(:,2),...
    stimLearn_var3, stimRecog_var3, stimNewOld_var3, imgPath(:,3),'VariableNames', ...
    {'stimLearn_var1', 'stimRecog_var1', 'stimNewOld_var1', 'imgPath_var1',...
    'stimLearn_var2', 'stimRecog_var2', 'stimNewOld_var2', 'imgPath_var2',...
    'stimLearn_var3', 'stimRecog_var3', 'stimNewOld_var3', 'imgPath_var3'});

% Save out table as .mat file to pull in to future analyses
save('newOld_stimID_all.mat', 'stimAll'); 