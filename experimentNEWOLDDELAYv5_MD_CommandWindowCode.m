% New/Old Task Command Window Code
%
% Syntax: experimentNEWOLDDELAYv5(variant, blockID, mode, mode2, eyeLinkMode, useCEDRUS)

%==Eyetracking==%
EyelinkInit(0);

for i=1:10
    Eyelink('Command', 'write_ioport 0x8 0xFF');
    Eyelink('Command', 'write_ioport 0x8 0x0');  % EyeLink 1000 Plus
pause(0.5);
end
disp('completed')

%Training (6 images for learning, 12 for recognition):
experimentNEWOLDDELAYv5_MDEyeTrack(1,51,100,0,1,0)    %learn
experimentNEWOLDDELAYv5_MDEyeTrack(1,51,200,0,1,0)    %recog

%Real (variant 1):
experimentNEWOLDDELAYv5_MDEyeTrack(1,1,100,0,1,0)     %learn, without eye track
experimentNEWOLDDELAYv5_MDEyeTrack(1,2,200,0,1,0)     %recog, without eye track 

%Real (variant 2):
experimentNEWOLDDELAYv5_MDEyeTrack(2,1,100,0,1,0)     %learn, without eye track
experimentNEWOLDDELAYv5_MDEyeTrack(2,2,200,0,1,0)     %recog, without eye track

%Real (variant 3):
experimentNEWOLDDELAYv5_MDEyeTrack(3,1,100,0,1,0)    %learn, with eye track
experimentNEWOLDDELAYv5_MDEyeTrack(3,2,200,0,1,0)    %recog, with eye track

%==No eyetracking==%
Datapixx('Open')
DatapixxAOttl() %FOR TTL

%Training (6 images for learning, 12 for recognition):
experimentNEWOLDDELAYv5_MD(1,51,100,0,0,0)    %learn
experimentNEWOLDDELAYv5_MD(1,51,200,0,0,0)    %recog

%Real (variant 1):
experimentNEWOLDDELAYv5_MD(1,1,100,0,1,0)     %learn, without eye track
experimentNEWOLDDELAYv5_MD(1,2,200,0,1,0)     %recog, without eye track 

%Real (variant 2):
experimentNEWOLDDELAYv5_MD(2,1,100,0,0,0)     %learn, without eye track
experimentNEWOLDDELAYv5_MD(2,2,200,0,0,0)     %recog, without eye track

%Real (variant 3):
experimentNEWOLDDELAYv5_MD(3,1,100,0,0,0)    %learn, with eye track
experimentNEWOLDDELAYv5_MD(3,2,200,0,0,0)    %recog, with eye track