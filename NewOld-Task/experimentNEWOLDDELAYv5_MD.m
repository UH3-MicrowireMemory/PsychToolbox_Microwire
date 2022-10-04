%============================Step 6: Run the task
%new/old delay task main file

% variant: which file to load (1/2/4).
% 1/2 are recog only. 4 is with src.
%
% 5 has src too (for color)
%
% blockID: which part of exp (1 learn, 2 recog1, 3 recog2, 51 train).
%
% mode1: which instructions to display. MODE_LEARN (100) or MODE_RECOG(200)
%
% mode2: with (1) or without src recall (0). default is without.
% mode2: =1 with spatial recall; =2 with background color recall
%
% eyeLinkMode: 0 no, 1 yes
%
%urut may05
%urut nov06 added src recall
%urut feb13 v5, has windows 7 TTLs and eye tracker capability.
%
% Modifications in current version by: 
% John A. Thompson & Marielle L. Darwin | May 27 2021
%===============================


function experimentNEWOLDDELAYv5_MD(variant, blockID, mode, mode2, eyeLinkMode, useCEDRUS)
if nargin<5
    error('Wrong parameters specified. variant (1,2,4), blockID, mode(100|200), mode2(0/1)');
end
if nargin<5
    eyeLinkMode=0; %eyelink=piece of equipment, not going to use now
end
if mode~=100 && mode ~= 200
    error('param error mode1. only 100/200 allowed.');
end
if mode2~=2 && mode2~=1 && mode2~=0
    error('param error mode2. only 0/1/2 allowed.');
end
MODE_SRC=1;
Screen('Preference','SkipSyncTests',1); %PTB to skip validating screen

%specify here where the images are stored
%basepath=['c:\svnwork\consortium\code\psychophysics\stimuli\'];  % images for experiments
%logDir = 'c:\experiments\logs\'; %where to log info while exp is running
basepath=('C:\Users\jatne\OneDrive\Documents\Cedars_microwire\code\psychophysics\stimuli\');  % images for experiments
logDir=('C:\Users\jatne\OneDrive\Documents\Cedars_log\'); %where to log info while exp is running

screenIDToUse=0; %0 main  %%psychtoolbox f(x)
%screenIDToUse=2;
screenNumber=max(Screen('Screens')); %screen to display
if screenNumber>0
    screenIDToUse=screenNumber;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sendTTL_enabled = 0; %%to sync with NLX for timestamps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


setMarkerIDs;   %set constants

STIM_WAIT_TIME = 1.0;   % how long is the stimulus displayed [in sec]. Default is 1s

if useCEDRUS
    %initialize CEDRUS keypad.
    try
        handle=initCEDRUS;
    catch
        CedrusResponseBox('CloseAll');
        handle=initCEDRUS;
    end
end

MODE_BLANK=1;
MODE_FREETEXT=14;

sansSerifFont = 'Arial';
%[window] = initializeScreens_PTB3(screenIDToUse);
black = BlackIndex(screenNumber);
white=[255 255 255];
[window, ~] = PsychImaging('OpenWindow', screenNumber, black);     %From BasicTextDemo.m
% load files
switch (variant)
    case 1
        load('newOldDelayStimuli.mat');
        load([ 'NewOldDelay_v3.mat']);
    case 2
        load([ 'newOldDelayStimuli2.mat']);
        load([ 'NewOldDelay2_v3.mat']);
        
    case 3
        load([ 'newOldDelayStimuli3.mat']);
        load([ 'NewOldDelay3_v3.mat']);
        
    case 4
        load([ 'newOldDelayStimuliSrc.mat']);
        load([ 'NewOldDelaySrc_v4.mat']);
    case 5
        load([ 'newOldDelayStimuliSrc2.mat']);
        load([ 'NewOldDelaySrc2_v4.mat']);
        
    case 6  % used to be var4, but moved to var6 to make var4 backward compatible
        
        load([ 'newOldDelayStimuliSrc.mat']);
        %load([ 'NewOldDelaySrc_v4.mat']);
        load('NewOldDelaySrc_v4_learnRepeats3.mat');
        
        STIM_WAIT_TIME = 1.0;
    case 7 % used to be var5, but moved to var7 to make var5 backward compatible
        load([ 'newOldDelayStimuliSrc2.mat']);
        %load([ 'NewOldDelaySrc2_v4.mat']);
        load([ 'NewOldDelaySrc2_v4_learnRepeats3_v2.mat']);
        STIM_WAIT_TIME = 1.0;
        
        
    case 8  %NO src, with repeated learning trials
        load([ 'newOldDelayStimuliSrc3.mat']);
        %load([ 'NewOldDelaySrc2_v4.mat']);
        load([ 'NewOldDelaySrc8_v1_learnRepeat.mat']);
        
        STIM_WAIT_TIME = 2.0;
        
        
    otherwise
        error('unkown variant');
end

%verify file is correct
if mode2>=MODE_SRC  %with SRC
    if mode==MODE_LEARN
        if length( experimentStimuli(blockID).stimuliLearn ) ~= length( experimentStimuli(blockID).recallPos )
            error('src mode requested but src info not available (learn)');
        end
    end
    if mode==MODE_RECOG
        if length( experimentStimuli(blockID).stimuliRecog ) ~= length( experimentStimuli(blockID).newOldRecall )
            error('src mode requested but src info not available (recog)');
        end
    end
end

CATEGORYNR_ANIMAL=5; %which category is the animal category

%for training,other category is animal
if blockID==50 || blockID==51
    CATEGORYNR_ANIMAL=6;
end

if length(experimentStimuli)<blockID
    disp('param error - stimuli block does not exist');
    return;
end

fileLabel='NEWOLDDELAY5';
[fidLog,fnameLog,timestampStr] = openLogfile(fileLabel, logDir);
logStr = [num2str(variant) ',' num2str(blockID) ',' num2str(mode) ',' num2str(mode2) ',v5'];
if eyeLinkMode
    writeLog_withEyelink(fidLog,0,logStr, 0);
end

till=0;
stimuliToLoad=[];
if mode==MODE_LEARN
    till = length ( experimentStimuli(blockID).stimuliLearn );
    stimuliToLoad = experimentStimuli(blockID).stimuliLearn;
    
    if mode2>=MODE_SRC
        recallPos = experimentStimuli(blockID).recallPos;
    else
        recallPos=[];
    end
    
else
    till = length ( experimentStimuli(blockID).stimuliRecog );
    stimuliToLoad = experimentStimuli(blockID).stimuliRecog;
    
    if mode2>=MODE_SRC
        newOldRecall = experimentStimuli(blockID).newOldRecall;
    else
        newOldRecall=[];
    end
    
end

if sendTTL_enabled
    %     config_io; %setup parallel port
    % DatapixxAOttl() %FOR TTL
else
    warning('send TTLs disabled');
end

%setup eye tracker
if eyeLinkMode
    dummymode=0;       % set to 1 to initialize in dummymode
    edffilename=['NO' timestampStr(end-5:end)];
    edffilename_local = [logDir 'NO' timestampStr '.edf'];
    retCode = eyeLink_setup_PTB3(window, dummymode, edffilename);
    
    if retCode~=1   % 1 means succeedeed
        %aborted
        terminateExperiment(window,fidLog,eyeLinkMode);
        display('Experiment aborted in eyelink setup screen');
        return;
    else
        
        Eyelink('Message', [fnameLog]);
        Eyelink('Message', logStr );
        
        Eyelink('command', 'record_status_message "NO exp init"');
        
    end
end

%==== display instructions screen and decide which question screens to use during the experiment
text=[];
if mode==MODE_LEARN
    if mode2 >= MODE_SRC
        if mode2==1 %spatial
            experimentNEWOLDDELAY_screens(2, window, basepath,till);
            modeToUse_QScreen1 = 8;
        else %color
            experimentNEWOLDDELAY_screens(3, window, basepath,till);
            modeToUse_QScreen1 = 9;
        end
    else
        modeToUse_QScreen1 = 10;
        experimentNEWOLDDELAY_screens(4, window, basepath,till);
    end
    
else
    modeToUse_QScreen1 = 11;  %new/old question with confidence
    if mode2 >= MODE_SRC
        if mode2==1
            %recog with recall spatial
            experimentNEWOLDDELAY_screens(5, window, basepath,till);
            modeToUse_QScreen2 = 12;
        else
            %recog with recall color
            experimentNEWOLDDELAY_screens(6, window, basepath,till);
            modeToUse_QScreen2 = 13;
        end
    else
        %recog, no recall
        experimentNEWOLDDELAY_screens(7, window, basepath,till);
        
        modeToUse_QScreen2 = -1; %na
    end
end

Screen('Flip',window);  %display the instructions
HideCursor;

%=== button press after instruction screen
if useCEDRUS
    waitForKeypressCedrus(handle, [6 7 8]);
else
    waitForKeypressPTB();
end

%-------------------start (start recording here)

%training
if sendTTL_enabled
    %     sendTTL(EXPERIMENT_ON_REAL);
    DatapixxAOttl() %FOR TTL
    writeLog_withEyelink(fidLog, EXPERIMENT_ON_REAL,'', eyeLinkMode);
end

countCorrectOld=0;
countCorrectNew=0;
countCorrectLearn=0;
countCorrectRecall=0;

%== display fixation cross screen
experimentNEWOLDDELAY_screens(MODE_BLANK, window, basepath,till);
plotCross_PTB3(window);
Screen('Flip',window);
WaitSecs(1.0)


%now do experiment
for i=1:till
    inputemu({'key_normal','H\BACKSPACE'}'); % Simulating keyboard input to prevent win going to sleep
    HideCursor;
    
    if eyeLinkMode
        Eyelink('command', ['record_status_message "TRIAL ' num2str(i) ' of ' num2str(till) '"']);
    end
    
    %    Screen('CopyWindow',w(i),window);
    experimentNEWOLDDELAY_screens(MODE_BLANK, window, basepath,till);
    
    fnameToLoad = fileMapping{stimuliToLoad(i)};
    fnameToLoad=strrep(fnameToLoad,'C:\code\images\',basepath);
    
    filename=[fnameToLoad];
    img=imread(filename);
    
    posImg=[];
    if mode2>=MODE_SRC && mode==MODE_LEARN
        
        if mode2==1 %spatial
            posImg =posImgHoriz(img, recallPos(i));
            %draw middle line
            Screen('DrawLine', window,white, 512, 0, 512, 768, 1); %vertical
        else
            %color
            posImg = centerImg(img);
            posColor=posImg;
            posColor(1) = posColor(1)-100;
            posColor(2) = posColor(2)-100;
            posColor(3) = posColor(3)+100;
            posColor(4) = posColor(4)+100;
            
            if recallPos(i)==1
                %Screen('FillRect',window,[0 0 1]*255 ); %blue
                Screen('FillRect',window,[0 1 0]*255, posColor  ); %green
            end
            
            if recallPos(i)==2
                %Screen('FillRect',window, [1 1 1]*255 ); %white
                Screen('FillRect',window, [1 0 0]*180, posColor ); %red
            end
        end
    else
        posImg = centerImg(img);
    end
    
    %--- show the image
    Screen('PutImage', window, img, posImg );
    Screen('Flip', window);
    if sendTTL_enabled
        %         sendTTL(STIMULUS_ON);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, STIMULUS_ON,'', eyeLinkMode);
    end
    if eyeLinkMode
        Eyelink('Message', ['TRIALID ' num2str(i) ' ' filename]);
    end
    
    WaitSecs(STIM_WAIT_TIME)
    
    experimentNEWOLDDELAY_screens(MODE_BLANK, window, basepath,till);
    Screen('Flip', window);
    
    if sendTTL_enabled
        %         sendTTL(STIMULUS_OFF);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, STIMULUS_OFF,'', eyeLinkMode);
    end
    
    WaitSecs(0.5)
    experimentNEWOLDDELAY_screens(modeToUse_QScreen1, window, basepath,till);
    Screen('Flip', window);
    
    if sendTTL_enabled
        %         sendTTL(DELAY1_OFF);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, DELAY1_OFF,'', eyeLinkMode);
    end
    
    emptyKeyboardBuffer;
    
    if mode==MODE_LEARN
        if useCEDRUS,
            CedrusResponseBox('FlushEvents', handle);
        else
            emptyKeyboardBuffer;
        end
        
        if useCEDRUS
            
            if mode2>=MODE_SRC
                [RT(i), buttonPressed] = waitForKeypressCedrus(handle, [4 5]);   % color box (green,red)
                
            else
                [RT(i), buttonPressed] = waitForKeypressCedrus(handle, [4 5]);   % Yes or no Box
            end
            
            if buttonPressed==4
                char='a';  %Yes
            else
                char=';';  %No
            end
        else
            
            char=' ';
            while (char~='a' && char ~=';' && char~='q' && char~='p' && char~='A' && char~='P' )
                [~,char]=waitForKeypressPTB();
                if char==''
                    char =' ';
                end
                if isempty(char)
                    char = ' ';
                end
            end
        end
        
        %disp(['pressed: #' char '#' ]);
        if char=='a' | char=='q' | char=='A' | char=='Q'
            if sendTTL_enabled
                DatapixxAOttl() %FOR TTL
                %                 sendTTL(RESPONSE_LEARNING_ANIMAL);
                writeLog_withEyelink(fidLog, RESPONSE_LEARNING_ANIMAL,'', eyeLinkMode);
            end
            
            if mode2>=MODE_SRC
                if recallPos(i) == 1
                    countCorrectLearn=countCorrectLearn+1;
                end
            else
                if ( categoryMapping(stimuliToLoad(i),2)) == CATEGORYNR_ANIMAL  %if is animal
                    countCorrectLearn=countCorrectLearn+1;
                end
            end
        end
        if char==';' | char=='p' | char==':' | char=='P'
            if sendTTL_enabled
                %                 sendTTL(RESPONSE_LEARNING_NONANIMAL);
                DatapixxAOttl() %FOR TTL
                writeLog_withEyelink(fidLog, RESPONSE_LEARNING_NONANIMAL,'', eyeLinkMode);
            end
            
            if mode2>=MODE_SRC
                if recallPos(i) == 2
                    countCorrectLearn=countCorrectLearn+1;
                end
            else
                if ( categoryMapping(stimuliToLoad(i),2) ) ~= CATEGORYNR_ANIMAL  %if is animal
                    countCorrectLearn=countCorrectLearn+1;
                end
            end
        end
    end
    
    if mode==MODE_RECOG
        
        
        if useCEDRUS,
            CedrusResponseBox('FlushEvents', handle);
        else
            emptyKeyboardBuffer;
        end
        
        if useCEDRUS
            [RT(i), buttonPressed] = waitForKeypressCedrus(handle, [2 3 4 5 6 7]);  % confidence box, shifted by one
            char=num2str(buttonPressed-1);
        else
            char=' ';
            %char~='z' && char ~='/' &&
            while  char ~='1' && char ~='2' && char ~='3' && char ~='4' && char ~='5' && char ~='6'
                [~,char]=waitForKeypressPTB();
                if char==''
                    char =' ';
                end
                if isempty(char)
                    char = ' ';
                end
            end
        end
        
        [respType] = getConfidence(fidLog, char, eyeLinkMode, sendTTL_enabled);
        
        if experimentStimuli(blockID).newOldRecog(i) == 1 && respType==1
            countCorrectOld=countCorrectOld+1;
        end
        
        if experimentStimuli(blockID).newOldRecog(i) == 0 && respType==0
            countCorrectNew=countCorrectNew+1;
        end
        
        %if recall mode, also ask for a confidence judgment on the source
        %(if answer was OLD)
        if mode2>=MODE_SRC &  respType==1
            
            experimentNEWOLDDELAY_screens(MODE_BLANK, window, basepath,till);
            Screen('Flip', window);
            
            WaitSecs(1.0)
            
            experimentNEWOLDDELAY_screens(modeToUse_QScreen2, window, basepath,till);
            Screen('Flip', window);
            
            sendTTL(DELAY2_OFF);
            writeLog_withEyelink(fidLog, DELAY2_OFF,'', eyeLinkMode);
            %===
            
            if useCEDRUS,
                CedrusResponseBox('FlushEvents', handle);
            else
                emptyKeyboardBuffer;
            end
            
            if useCEDRUS
                [RT(i), buttonPressed] = waitForKeypressCedrus(handle, [2 3 4 5 6 7]);  % confidence box, shifted by one
                
                char=num2str(buttonPressed-1);
                
                %if buttonPressed==4
                %    char='a';  %Yes
                %else
                %    char=';';  %No
                %end
            else
                
                
                char=' ';
                %char~='z' && char ~='/' &&
                while  char ~='1' && char ~='2' && char ~='3' && char ~='4' && char ~='5' && char ~='6'
                    [~,char]=waitForKeypressPTB();
                    if char==''
                        char =' ';
                    end
                    if isempty(char)
                        char = ' ';
                    end
                end
            end
            
            [respType] = getConfidence(fidLog, char, eyeLinkMode, sendTTL_enabled);
            
            if experimentStimuli(blockID).newOldRecall(i) == 1 && respType==0
                countCorrectRecall=countCorrectRecall+1;
            end
            
            if experimentStimuli(blockID).newOldRecall(i) == 2 && respType==1
                countCorrectRecall=countCorrectRecall+1;
            end
        end
    end
    
    experimentNEWOLDDELAY_screens(MODE_BLANK, window, basepath,till);
    plotCross_PTB3(window);
    Screen('Flip', window);
    
    WaitSecs(1.0)
    if sendTTL_enabled
        %         sendTTL(DELAY2_OFF);
        DatapixxAOttl() %FOR TTL
    end
    writeLog_withEyelink(fidLog, DELAY2_OFF,'', eyeLinkMode);
end

if sendTTL_enabled
    %     sendTTL(EXPERIMENT_OFF);
    DatapixxAOttl() %FOR TTL
end
writeLog_withEyelink(fidLog, EXPERIMENT_OFF,'',eyeLinkMode);

%display result
text=[];
if blockID==51 % Practice blocks
    text{1}='Thank you! Your performance was :';
    text{2}='';
    if mode==MODE_LEARN
        text{3}=[' =>> Number of images correctly identified  ' num2str(countCorrectLearn) ' ( ' num2str(((countCorrectLearn)*100)/till,3) '% )'];
        text{4}='';
        text{5}='';
        text{6}='';
        text{7}='';
        text{8}='';
        text{9}='';
        text{10}='Please tell experimenter that you are finished.';
    end
    if mode==MODE_RECOG
        text{3}=[' =>> Number of images correctly identified  ' num2str(countCorrectOld+countCorrectNew) ' ( ' num2str(((countCorrectOld+countCorrectNew)*100)/till,3) '% )'];
        text{4}='';
        text{5}=['Number of images correctly identified as OLD ' num2str(countCorrectOld)];
        text{6}=['Number of images correctly identified as NEW ' num2str(countCorrectNew)];
        
        if mode2>=MODE_SRC
            text{7}=['Number of OLD pictures position/color correctly remembered:  ' num2str(countCorrectRecall) ' of ' num2str(countCorrectOld)];
        else
            text{7}='';
        end
        
        text{8}='';
        text{9}='';
        text{10}='Please tell the experimenter that you are finished.';
    end
else % Non-practice blocks
    text{1}='Thank you! Please tell the researcher that you are finished.';
end

%=display feedback screen
experimentNEWOLDDELAY_screens(MODE_FREETEXT, window, basepath,text);
Screen('Flip', window);

emptyKeyboardBuffer;
% == wait for keypress to erase results screen
if useCEDRUS
    waitForKeypressCedrus(handle, [6 7 8]);
else
    [~,char]=waitForKeypressPTB();
end

if eyeLinkMode
    disp(['Receving file and store to:' edffilename ' to ' edffilename_local]);
    status=Eyelink('ReceiveFile', edffilename, edffilename_local);
end

terminateExperiment(window,fidLog,eyeLinkMode);

%====== internal functions


function terminateExperiment(window,fidLog,eyeLinkMode)
if eyeLinkMode
    Eyelink('Message', 'Regular Stop');
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    
    
    Eyelink('Shutdown');
    
end

closeScreens(window);
fclose(fidLog);
clear Snd;  % eyelink toolbox opens sound.

%
%get the confidence rating and add log entry/send TTL for it
%
function [respType] = getConfidence(fidLog, char, eyeLinkMode, sendTTL_enabled)
setMarkerIDs;

respType=1; %OLD
if char=='/' || char=='6'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_6);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_6,'',eyeLinkMode);
    end
end

if char=='5'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_5);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_5,'',eyeLinkMode);
    end
end

if char=='4'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_4);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_4,'',eyeLinkMode);
    end
end

if char=='3'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_3);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_3,'',eyeLinkMode);
    end
    respType=0; %NEW
end

if char=='2'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_2);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_2,'',eyeLinkMode);
    end
    respType=0; %NEW
end

if char=='1' || char=='z'
    if sendTTL_enabled
        %         sendTTL(RESPONSE_1);
        DatapixxAOttl() %FOR TTL
        writeLog_withEyelink(fidLog, RESPONSE_1,'',eyeLinkMode);
    end
    respType=0; %NEW
end