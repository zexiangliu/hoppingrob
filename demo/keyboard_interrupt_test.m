function keyboard_interrupt_test()
desktop     = com.mathworks.mde.desk.MLDesktop.getInstance;
cw          = desktop.getClient('Command Window');
xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);
h_cw        = handle(xCmdWndView,'CallbackProperties');
set(h_cw, 'KeyPressedCallback', @CmdWinKeyCallback);
num = 1;
CmdWinKeyCallback('reset');
while true
    disp('hello');
    pause(5);
    disp('world!');
    if CmdWinKeyCallback()
        disp(['Key pressed ' num2str(num)]);  
        disp('type ''dbcont'' to continue')
        keyboard
        CmdWinKeyCallback('reset');
        disp('resuming')
        num = num+1;
    end
end
end
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