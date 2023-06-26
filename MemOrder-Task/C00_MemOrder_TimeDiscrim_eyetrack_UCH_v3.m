%% Temporal discrimination task: identity which image shows first (left or right)
% Inter-trial interval is 0.5 second
% Each set of image (two images) lasts 1.5 second:
% Response LEFT or RIGHT, self-paced, reponse within 2 seconds
% TTL pulses were sent at CrossStart, ClipStart, ClipEnd
%
% Output file: respMat_TimDiscrim, a structure variable with log info
%   respMat_TimDiscrim.CrossStart: time onset of fixation period in second
%   respMat_TimDiscrim.CrossEnd: time offset of fixation period in second
%   respMat_TimDiscrim.FrameStart: time onset of frame display period in second
%   respMat_TimDiscrim.FrameEnd: time offset of frame display period in second
%   respMat_TimDiscrim.FrameName: filename of the frame image
%   respMat_TimDiscrim.QuesStart: time onset of random question period in second
%   respMat_TimDiscrim.respValue: subjects' response value including
%                      -3 = LEFT, SURE                 3 = RIGHT, SURE
%                      -2 = LEFT, LESS SURE            2 = RIGHT, LESS SURE
%                      -1 = LEFT, VERY UNSURE          1 = RIGHT, VERY UNSURE
%   or if Cedrus response box is used, then
%                      2 = NO, SURE                  5 = YES, SURE
%                      3 = NO, LESS SURE             6 = YES, LESS SURE
%                      4 = NO, VERY UNSURE           7 = YES, VERY UNSURE
%   respMat_TimDiscrim.respTime: timestamp when subject presses the button in second


% try
%--------------------------------------------------------------------------
%                       PTB setup
%--------------------------------------------------------------------------
% clear all
% clc
% sca;
% commandwindow;
% config_io
%HideCursor;
% PsychDefaultSetup(2);
%Screen('Preference','SkipSyncTests',1); % skip screen test
Screen('Preference','SyncTestSettings', 0.005,50, 0.3,5); % screen syncing
% Check if Psychtoolbox is properly installed:
AssertOpenGL;
if IsWin && ~IsOctave && psychusejava('jvm')
    fprintf('Running on Matlab for Microsoft Windows, with JVM enabled!\n');
    fprintf('This may crash. See ''help GStreamer'' for problem and workaround.\n');
    warning('Running on Matlab for Microsoft Windows, with JVM enabled!');
end

%--------------------------------------------------------------------------
%                       Display setup
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%% Screen Feature Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the screen number to the external secondary monitor if there is one
% connected
screenid = max(Screen('Screens'));
% Define black, white and grey
white = WhiteIndex(screenid);
gray = GrayIndex(screenid);
black = BlackIndex(screenid);
%%% TESTING: Smaller screen, switch to full screen for real experiment
%para.windowRect_define = [0 0 1370 680]; % 13.3inch mac is 2560 x 1600
para.windowRect_define = [0 0 1920 1050]; % UCH Thinkpad with Eyetracking
%%% TESTING: Open 'windowrect' sized window, switch to full screen for real experiment
[window, windowRect] = PsychImaging('OpenWindow', screenid, gray, para.windowRect_define); % resized screen
% [window, windowRect] = PsychImaging('OpenWindow', screenid, gray); % full screen
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

%%%%%%%%%%%% Scaled Text (instruction and question) Setup %%%%%%%%%%%%%%%%%
% Get size of the on screen window
screenXpixels  = windowRect(3);
screenYpixels  = windowRect(4);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Load example image. Instruction and question are the same size
theImg_text=imread(fullfile(pwd,'\E00_InstruText\C01_TimDisInstruText.png')); % 1066 X 1422
% Get the size of the image
[orig_width_text, orig_height_text, ~]=size(theImg_text);
% Define the fraction of scale, this is for Y axis match between img and screen
heightScaler_text = 0.8; % 80% height of the screen y axis
imgHeight_text = screenYpixels * heightScaler_text;
imgWidth_text = imgHeight_text * orig_height_text / orig_width_text;
theRect_text = [0 0 imgWidth_text imgHeight_text];
dstRect_text = CenterRectOnPointd(theRect_text, screenXpixels/2, screenYpixels/2);
% %%% TESTING: Draw the image to the center of the screen with scaled size
% % Make the image into a texture
% theTexture = Screen('MakeTexture', window, theImg_text);
% Screen('DrawTextures', window, theTexture, [], dstRect_text);
% Screen('Flip', window);% Flip to the screen
% KbStrokeWait;% Wait for Key press
% sca% Clear the screen

%%%%%%%%%%%%%%%%%%%%%%%% Scaled Image Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load example image. Instruction and question are the same size
theImg=imread(fullfile(pwd,'\C01_TimeDisImg\Img_first\HB_1cut_1_1.png')); % 960 x 540
% Get the size of the image
[orig_width, orig_height, ~]=size(theImg);
% Define the fraction of scale, this is for Y axis match between img and screen
heightScaler = 0.4; % 80% height of the screen y axis
imgWidth = screenXpixels * heightScaler;
imgHeight = imgWidth * orig_width / orig_height;
theRect = [0 0 imgWidth imgHeight];
dstRect_left = CenterRectOnPointd(theRect, screenXpixels/4, screenYpixels/2);
dstRect_right = CenterRectOnPointd(theRect, (screenXpixels/4)*3, screenYpixels/2);
% %%% TESTING: Draw the image to the center of the screen with scaled size
% % Make the image into a texture
% theTexture = Screen('MakeTexture', window, theImg);
% Screen('DrawTextures', window, theTexture, [], dstRect);
% Screen('Flip', window);% Flip to the screen
% KbStrokeWait;% Wait for Key press
% sca% Clear the screen

%%%%%%%%%%%%%%%%%% Scaled Inter-trial Fixation Cross Setup %%%%%%%%%%%%%%%%
% Screen Y axis fraction for fixation cross
crossFrac = 0.0167;
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = screenYpixels * crossFrac;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;
% Duration for fixation cross in seconds
itiTimeSecs = 0.5;
% Duration for frame display in seconds:
para.frameTimeSecs = 2;
% Duration ofr question period in seconds:
para.QuesTimeSecs = 5;

%--------------------------------------------------------------------------
%                   Experiment Parameter Setup
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%% Script Execution Warm Up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set priority for script execution to realtime priority:
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%% SUBJECT ID --- MUST CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
para.sub_id = 'MWtest';
%%%%%%%%%%%%%%%%%%% SUBJECT ID --- MUST CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%% Experiement Features Define %%%%%%%%%%%%%%%%%%%%%%%%%%
para.Ntrial = 90; % the total number of trials, FIXME later
% Seed for the random number generator
rng('shuffle','twister');
% clip list folder
para.frameDIR = fullfile(pwd,'\C01_TimeDisImg\'); % stimuli directory

%%%%%%%%%%%%%%%%%%%% Experiement Keyboard SetUp %%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
spaceKey = KbName('space');
try
    escapeKey = KbName('Esc');
catch
    escapeKey = KbName('Escape');
end
NoSureKey = KbName('s');
NoLessSureKey = KbName('d');
NoVeryUnsureKey = KbName('f');
YesVeryUnsureKey = KbName('j');
YesLessSureKey = KbName('k');
YesSureKey = KbName('l');
pauseKey = KbName('Tab'); % Save the key for pause, FIXME later

%%%%%%%%%%%%%%%%%%%% Experiement Output SetUp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the helper_files into the working path, which contains subfunctions
addpath([pwd, '\helper_files']);

para.output_filename = fullfile(pwd,['\D00_Logs\',para.sub_id,'_timeDiscrim.mat']);
%HideCursor;
% check for existing result file to prevent accidentally overwriting
% files from a previous subject/session (except for subject numbers > 99):
if isempty(para.sub_id)
    Priority(0);
    fprintf('Please restart and enter the subject id');
    ShowCursor; sca; return;
elseif fopen(para.output_filename, 'rt') ~= -1
    Priority(0);
    fprintf('The file name already exists, please change to another one');
    ShowCursor; sca; return;
end

% Setup for EyeLink1000
para.eyelink_flag = 1; % Will use EyeLink1000 for eye tracking? 1 = YES, 0 = NO
fileLabel = [para.sub_id, '_timeDiscrim_eye_'];
[para.eyefidLog, para.eyefnameLog, para.eyeTimestampStr] = openLogfile(fileLabel,[pwd,'\D00_Logs\eyeLogs\']);
para.eyedata_filename = [pwd,'\D00_Logs\', fileLabel, para.eyeTimestampStr,'.mat'];
if para.eyelink_flag % set up eyelink for eye tracking
    dummymode = 0;       % set to 1 to initialize in dummymode
    retCode = eyeLink_setup_PTB3(window, dummymode, ['Ti_' para.eyeTimestampStr(end-5:end-2)]);
    if retCode % success connected
        Eyelink('Message', para.eyefnameLog);
    else
        Priority(0);
        fprintf('Experiment aborted due to the failure of eye link setup');
        ShowCursor; sca; return
    end
end

% Need to send TTL pulses?
para.TTL_flag = 1;
if para.TTL_flag
    para.TTL.task_onset = 61;
    para.TTL.fix_cross = 11;
    para.TTL.img_onset = 1;
    para.TTL.img_offset = 2;
    para.TTL.probe = 3;
    para.TTL.response = 4;
    para.TTL.task_offset = 60;
    para.TTL.afterTTLDelay=0;  %in secs, wait till reset of TTL to 0
    % open cpod for preparation
    %openTTL_cpod('COM3');
end

recordingDate = clock;
respMat_TimeDis= []; % Initialize the variable to store log information
errorMsg = []; % Intialize the variable to store error messages


%--------------------------------------------------------------------------
%                        Load Task Instruction
%--------------------------------------------------------------------------
% Restrict Key to escape and space
RestrictKeysForKbCheck([spaceKey escapeKey]);
FrameImg=imread(fullfile(pwd,'\E00_InstruText\C01_TimDisInstruText.png'));
% make texture image out of image matrix 'imdata'
FrameTex=Screen('MakeTexture', window, FrameImg);
% Draw texture image to backbuffer.
Screen('DrawTexture', window, FrameTex,[], dstRect_text); % proportional display
% Show instructions on screen at next possible display refresh cycle
Screen('Flip', window);
[~, KeyCode, ~] = KbPressWait;
% Check the KeyCode for different function
if KeyCode(escapeKey)
    Priority(0);
    errorMsg = {'User pressed ESC, quit task at Instruction phase'};
    ShowCursor;
    save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca;
end
if KeyCode(spaceKey)
    Screen('Flip', window);
end

%--------------------------------------------------------------------------
%                        Load Practice Trial
%--------------------------------------------------------------------------
eg_file = {'C02_Example_1','C02_Example_2', 'ready'};
egs_n = length(eg_file);
for n_eg = 1:egs_n
    egImg = imread([pwd,'\E00_InstruText\',eg_file{n_eg}, '.png']);
    egTex = Screen('MakeTexture', window, egImg);
    Screen('DrawTexture', window, egTex,[], dstRect_text); % proportional display
    Screen('Flip', window);
    [~, KeyCode, ~] = KbPressWait;
    % Check the KeyCode for different function
    if KeyCode(escapeKey)
        Priority(0);
        errorMsg = {'User pressed ESC, quit task at Instruction phase'};
        ShowCursor;
        save(para.output_filename,'recordingDate','respMat','errorMsg','para'); sca;
    end
    if KeyCode(spaceKey)
        Screen('Flip', window);
    end
end

%--------------------------------------------------------------------------
%                        Start Real Experiment
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%% Scan frame folder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameList = dir([para.frameDIR,'Img_first\*.png']);
frameList2 = dir([para.frameDIR,'Img_second\*.png']);
para.frameNum = length(frameList);
% Check whether video clips number matches with trial number
if para.frameNum ~= para.Ntrial
    Priority(0);
    errorMsg = {'Not all the frame images are included'};
    ShowCursor;
    save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca;
end
% pre-load question image, since it's the same for all the trials, no need
% to add into the for loop
QuesImg=imread(fullfile(pwd,'\E00_InstruText\C03_QuesText.png'));
% make texture image out of image matrix 'QuesImg'
QuesTex=Screen('MakeTexture', window, QuesImg);

if para.TTL_flag
    writeLog_withEyelink(para.eyefidLog,para.TTL.task_onset,'', 1)
    sendTTLeyelink_jat(para.TTL.task_onset);
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Single trial SetUp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restrict Key to escape, left and right
RestrictKeysForKbCheck([escapeKey pauseKey]); % only enable the escape key for the fixation and image display period
trial_indx = 0; % count the trial number
for trial_n = randperm(para.frameNum,para.frameNum)
    %inputemu({'key_normal','H\BACKSPACE'});

    trial_indx = trial_indx + 1;
    if para.eyelink_flag
        Eyelink('command', ['record_status_message "TRIAL ' num2str(trial_indx) ' of ' num2str(para.Ntrial) '"']);
    end
    %%%%%%%%%%%%%%%% Fixation period (0.5s)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('DrawLines', window, fixCoords, lineWidthPix, white, [xCenter yCenter]);
    [~, startrt] = Screen('Flip', window);
    % Send a TTL pulse to mark the onset of fixation cross and save this baseline onset in the respMat
    if para.TTL_flag

        writeLog_withEyelink(para.eyefidLog,para.TTL.fix_cross ,'', 1);
        sendTTLeyelink_jat(para.TTL.fix_cross);

    end
    respMat_TimeDis(trial_indx).CrossStart = double(startrt);
    % add jitter to fixation cross
    para.itiTimeSecs(trial_indx) = itiTimeSecs - (randperm(500,1)/1000-0.25);
    % Show fixation cross until the ITI duration elapsed or
    % the 'escapeKey' is pressed to quit the experiment
    while (GetSecs - startrt)<= para.itiTimeSecs(trial_indx)
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            Priority(0);
            errorMsg = {['user pressed ESC, quit task during the encoding at the fixation cross of trial ', num2str(trial_indx)]};
            ShowCursor;
            % close Eyelink, save files
            disp(['Receving file and store to:' ['Ti_' para.eyeTimestampStr(end-5:end-2)]]);
            status=Eyelink('ReceiveFile', ['Ti_' para.eyeTimestampStr(end-5:end-2)], ['Ti_' para.eyeTimestampStr(end-5:end-2) '.edf']);
            Eyelink('Message', 'Unfinished Stop');
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            fclose(para.eyefidLog);
            save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca; return;
        end
        %%%%%%%% Added pause key by JZ %%%%%%%%%
        if keyCode(pauseKey)
            Screen('Flip', window);
            pause
        end
        % Wait 1 ms before checking the keyboard again to prevent
        % overload of the machine at elevated Priority():
        WaitSecs(0.001);
    end
    Screen('Flip', window);
    respMat_TimeDis(trial_indx).CrossEnd = double(GetSecs);
    WaitSecs(0.01);

    %%%%%%%%%%%%%%%%%%%%%%% Frame display period (1s) %%%%%%%%%%%%%%%%%%%%%
    FrameImg_first =imread([pwd,'\C01_TimeDisImg\Img_first\', frameList(trial_n).name]);
    FrameImg_second =imread([pwd,'\C01_TimeDisImg\Img_second\', frameList2(trial_n).name]);
    % make texture image out of image matrix 'FrameImg'
    FrameTex_first=Screen('MakeTexture', window, FrameImg_first);
    FrameTex_second=Screen('MakeTexture', window, FrameImg_second);
    LR_indx = randperm(2);
    dstRect = [dstRect_left;dstRect_right];
    % Draw texture image to backbuffer.
    Screen('DrawTexture', window, FrameTex_first,[], dstRect(LR_indx(1),:)); % proportional display
    Screen('DrawTexture', window, FrameTex_second,[], dstRect(LR_indx(2),:)); % proportional display
    % Show instructions on screen at next possible display refresh cycle
    [~, startrt_frame] = Screen('Flip', window);
    % Send a TTL pulse to mark the onset of the image and save img_onset to the variable 'respMat_TimDis'
    if para.TTL_flag
        % sendTTLsEYElink(para.TTL.img_onset,trial_indx,para.eyefidLog,para.TTL.afterTTLDelay,para.eyelink_flag);
        % sendTTL_cpod(para.TTL.img_onset);

        trialInfo = ['trial ' , num2str(trial_indx)];
        writeLog_withEyelink(para.eyefidLog, para.TTL.img_onset,trialInfo,1)
        sendTTLeyelink_jat(para.TTL.img_onset)



    end
    respMat_TimeDis(trial_indx).FrameStart = double(startrt_frame);
    respMat_TimeDis(trial_indx).FrameName = frameList(trial_n).name;
    respMat_TimeDis(trial_indx).FrameOrder = LR_indx;
    while (GetSecs - startrt_frame) <= para.frameTimeSecs
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            Priority(0);
            errorMsg = {['user pressed ESC, quit task during the encoding at the frame display of trial ', num2str(trial_indx)]};
            ShowCursor;
            % close Eyelink, save files
            disp(['Receving file and store to:' ['Ti_' para.eyeTimestampStr(end-5:end-2)]]);
            status=Eyelink('ReceiveFile', ['Ti_' para.eyeTimestampStr(end-5:end-2)], ['Ti_' para.eyeTimestampStr(end-5:end-2) '.edf']);
            Eyelink('Message', 'Unfinished Stop');
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            fclose(para.eyefidLog);
            save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca; return;
        end
        %%%%%%%% Added pause key by JZ %%%%%%%%%
        if keyCode(pauseKey)
            Screen('Flip', window);
            pause
        end
        % Wait 1 ms before checking the keyboard again to prevent
        % overload of the machine at elevated Priority():
        WaitSecs(0.001);
    end
    Screen('Flip', window);
    if para.TTL_flag
        % sendTTLsEYElink(para.TTL.img_offset,trial_indx,para.eyefidLog,para.TTL.afterTTLDelay,para.eyelink_flag);
        %sendTTL_cpod(para.TTL.img_offset);

        trialInfo = ['trial ' , num2str(trial_indx)];
        writeLog_withEyelink(para.eyefidLog, para.TTL.img_offset,trialInfo,1)
        sendTTLeyelink_jat(para.TTL.img_offset)
    end
    respMat_TimeDis(trial_indx).FrameEnd = double(GetSecs);
    WaitSecs(0.01);

    %%%%%%%%%%%%%%% Question Period (self-paced, up to 2s) %%%%%%%%%%%%%%%%
    RestrictKeysForKbCheck([escapeKey NoSureKey NoLessSureKey NoVeryUnsureKey ...
        YesVeryUnsureKey YesLessSureKey YesSureKey pauseKey]);
    % Draw texture image to backbuffer.
    Screen('DrawTexture', window, QuesTex,[],dstRect_text); % proportional display, no rotation
    % Show question on screen at next possible display refresh cycle,
    % and record question onset time in 'startrt':
    Screen('Flip', window);
    if para.TTL_flag
        % sendTTLsEYElink(para.TTL.probe,trial_indx,para.eyefidLog,para.TTL.afterTTLDelay,para.eyelink_flag);
        %    sendTTL_cpod(para.TTL.probe);
        trialInfo = ['trial ' , num2str(trial_indx)];
        writeLog_withEyelink(para.eyefidLog, para.TTL.probe,trialInfo,1)
        sendTTLeyelink_jat(para.TTL.probe)


    end
    respMat_TimeDis(trial_indx).QuesStart = double(GetSecs);
    % start Response screen (not a loop! - wait for resp), KbPressWait
    % is not used here because there is 5ms delay
    respMat_TimeDis(trial_indx).respValue = [];
    % Now we wait for a keyboard button signaling the observers response.
    % You can also press escape if you want to exit the program
    para.cedrus_flag = 0;
    if para.cedrus_flag
        %  CedrusResponseBox('FlushEvents', handle); % clear up the previous button press
        %  CedrusResponseBox('ResetRTTimer', handle);
        % while 1
        %   % Check whether the 'esc' was pressed to quit the experiment
        %   [keyIsDown,secs, keyCode] = KbCheck;
        %   if keyCode(escapeKey)
        %       Priority(0);
        %       errorMsg = {['user pressed ESC, quit task during the encoding at the random question of trial ', num2str(trial_indx)]};
        %       ShowCursor;
        %        % close Eyelink, save files
        %      disp(['Receving file and store to:' ['Ti_' para.eyeTimestampStr(end-5:end-2)]]);
        %      status=Eyelink('ReceiveFile', ['Ti_' para.eyeTimestampStr(end-5:end-2)], ['Ti_' para.eyeTimestampStr(end-5:end-2) '.edf']);
        %      Eyelink('Message', 'Unfinished Stop');
        %      Eyelink('StopRecording');
        %      Eyelink('CloseFile');
        %      fclose(para.eyefidLog);
        %       save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca; return
        %   end
        %  evt = CedrusResponseBox('GetButtons', handle);
        %   if (GetSecs - respMat_TimeDis(trial_indx).QuesStart) > para.QuesTimeSecs
        %       break;
        %   end
        %   if ~isempty(evt) && evt.button ~= 8
        %       RT = evt.rawtime;
        %       % send a TTL pulse to mark the reponse time and save this response time to the respMat
        %       if para.TTL_flag
        %          sendTTLsEYElink(para.TTL.response,[RT,evt.button],para.eyefidLog,para.TTL.afterTTLDelay,para.eyelink_flag);
        %       %   sendTTL_cpod(para.TTL.response);
        %       end
        %       respMat_TimeDis(trial_indx).respValue = evt.button; break;
        %   end
        %  end
        % evt = [];
        % CedrusResponseBox('FlushEvents', handle);
    else
        while (GetSecs - respMat_TimeDis(trial_indx).QuesStart) <= para.QuesTimeSecs
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                Priority(0);
                errorMsg = {['user pressed ESC, quit task during the encoding at question session of trial ', num2str(trial_indx)]};
                ShowCursor;
                % close Eyelink, save files
                disp(['Receving file and store to:' ['Ti_' para.eyeTimestampStr(end-5:end-2)]]);
                status=Eyelink('ReceiveFile', ['Ti_' para.eyeTimestampStr(end-5:end-2)], ['Ti_' para.eyeTimestampStr(end-5:end-2) '.edf']);
                Eyelink('Message', 'Unfinished Stop');
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                fclose(para.eyefidLog);
                save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para'); sca; return
            elseif keyCode(NoSureKey)
                respMat_TimeDis(trial_indx).respValue = -3; % LEFT, Sure
                respToBeMade = false;
                ttlResponse = 111;
            elseif keyCode(NoLessSureKey)
                respMat_TimeDis(trial_indx).respValue = -2; % LEFT, Less Sure
                respToBeMade = false;
                ttlResponse = 112;
            elseif keyCode(NoVeryUnsureKey)
                respMat_TimeDis(trial_indx).respValue = -1; % LEFT, Very Unsure
                respToBeMade = false;
                ttlResponse = 113;
            elseif keyCode(YesVeryUnsureKey)
                respMat_TimeDis(trial_indx).respValue = 1; % RIGHT, Very Unsure
                respToBeMade = false;
                ttlResponse = 114;
            elseif keyCode(YesLessSureKey)
                respMat_TimeDis(trial_indx).respValue = 2; % RIGHT, Less Sure
                respToBeMade = false;
                ttlResponse = 115;
            elseif keyCode(YesSureKey)
                respMat_TimeDis(trial_indx).respValue = 3; % RIGHT, Sure
                respToBeMade = false;
                ttlResponse = 116;
            end

            % ADD TTL info
            if ~respToBeMade
                trialInfo = ['trial ' , num2str(trial_indx)];
                writeLog_withEyelink(para.eyefidLog, ttlResponse,trialInfo,1)
                sendTTLeyelink_jat(ttlResponse)
            end

        end
    end
    respMat_TimeDis(trial_indx).respTime = double(secs); %get time of response
end


% Send a TTL pulse to mark the end of the task
if para.TTL_flag
    % sendTTLsEYElink(para.TTL.task_offset,trial_indx,para.eyefidLog,para.TTL.afterTTLDelay,para.eyelink_flag);

    writeLog_withEyelink(para.eyefidLog, para.TTL.task_offset,'',1)
    sendTTLeyelink_jat(para.TTL.task_offset)


    %  sendTTL_cpod(para.TTL.task_offset);
    pause(0.5);
    % close cpod for future use
    %closeTTL_cpod('COM3');
    %closeTTL_cpod('COM3');
    disp(['Receving file and store to:' ['Ti_' para.eyeTimestampStr(end-5:end-2)]]);
    status=Eyelink('ReceiveFile', ['Ti_' para.eyeTimestampStr(end-5:end-2)], ['Ti_' para.eyeTimestampStr(end-5:end-2) '.edf']);
    Eyelink('Message', 'Regular Stop');
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    %Eyelink('Shutdown');
    fclose(para.eyefidLog);
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Save Output File %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(para.output_filename,'recordingDate','respMat_TimeDis','errorMsg','para');
% Close Screen, we're done:
sca;
ShowCursor;
fclose('all');
Priority(0);
% Output the error message that describes the error:
psychrethrow(psychlasterror);

% catch %#ok<CTCH>
%     % catch error: This is executed in case something goes wrong in the
%     % 'try' part due to programming error etc.:
%     % Do same cleanup as at the end of a regular session...
%     sca;
%     ShowCursor;
%     fclose('all');
%     Priority(0);
%     % Output the error message that describes the error:
%     psychrethrow(psychlasterror);
% end