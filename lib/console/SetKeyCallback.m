function SetKeyCallback()
    desktop     = com.mathworks.mde.desk.MLDesktop.getInstance;
    cw          = desktop.getClient('Command Window');
    xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);
    h_cw        = handle(xCmdWndView,'CallbackProperties');
    set(h_cw, 'KeyPressedCallback', @KeyCallback);
end