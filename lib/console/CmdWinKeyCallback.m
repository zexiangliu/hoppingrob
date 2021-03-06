function Value = CmdWinKeyCallback(ObjectH, EventData)
persistent KeyPressed
switch nargin
  case 0
    Value = ~isempty(KeyPressed);
  case 1
    KeyPressed = [];
  case 2
    if get(EventData,'keyCode')==27 % 27 = 'Esc'
        KeyPressed = true;
    else
        KeyPressed = [];
    end
  otherwise
    error('Programming error');
end  
end