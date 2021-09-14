%
% sends a TTL value
%
% this needs to be modified according to the PC that is used.
% 888 is for parallel port.
%
% for PCIExpress card, this value varies (find out in device manager).
%
%
function sendTTL(TTLValue)

%32-bit windows, windows XP
% writeIOw('3BC', TTLValue);

%64 bit windows, 32bit matlab or 64bit matlab (call correct input_io io32
%or io64)

% outp(888, TTLValue); %NOTE: this line is original from Ueli
%   Eyelink('Command', 'write_ioport 0x8 0xFF'); JAT not sure if needed !!!
  message = ['write_ioport 0x8 ',num2str(TTLValue)];
%   Eyelink('Command', 'write_ioport 0x8 0x0');
  Eyelink('Command', message)


%outp(49144, TTLValue);