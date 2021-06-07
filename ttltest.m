EyelinkInit(0);

for i=1:10
    Eyelink('Command', 'write_ioport 0x8 0xFF');
    Eyelink('Command', 'write_ioport 0x8 0x0');  % EyeLink 1000 Plus
pause(0.5);
end
disp('completed')