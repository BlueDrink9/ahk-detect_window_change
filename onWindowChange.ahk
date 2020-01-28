class WindowChangeDetector {

    __New(callbackFunction, debug=True)
    {
        this.callbackFunction := callbackFunction
        this.initMessageAddress()
        ; this.debug := debug
        if (debug){
            this.makeDebugGui()
            this.debug("Initiated debugger")
        }

        ; Get the dynamic identifier for shell messages and assign our callback to handle these messages
        static SHELL_MSG := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
        OnMessage(SHELL_MSG, Func("this.ShellCallback"))

        this.SetHook()

        return this  ; This line can be omitted when using the 'new' operator.
    }

    initMessageAddress(){
        ; Sets hWnd
        Gui +HwndhWnd
        msgbox %hWnd%
        ; A window handle is needed for sendmessage. Windows needs to a window
        ; to send message to, not just a process.
        this.windowHandle := hWnd
    }

    makeDebugGui(){
        Debug_Gui.debug:=this.debug
        this.debugWindow := new Debug_Gui
    }

    ; Sets whether the shell hook is registered
    SetHook() {
        if (!DllCall("RegisterShellHookWindow", "Ptr", this.windowHandle)) {
            msgbox Failed to register shell hook for detecting window change
            return false
        }
        this.debug("Registered shell hook for window handle '" . this.windowHandle . "'")
    }
    ; Shell messages callback
    ShellCallback(wParam, lParam) {
        ; HSHELL_WINDOWACTIVATED = 4, HSHELL_RUDEAPPACTIVATED = 0x8004
        ; tooltip % wParam " " (wParam & 4)
        ; msgbox % wParam " " (wParam & 4)
        debugWindow.Println("wParam: " wParam ",(wParam & 4): " (wParam & 4))
        if (wParam & 4) {
            ; lParam = hWnd of activated window
            this.informCallbackOfWindowChange()
        }
    }
    informCallbackOfWindowChange(){
        func := this.callbackFunction
        debugWindow.Println("Active window changed. Running callback func '%func%'")
        %func%()
        ; updateWorkraveState()
    }

    debug(msg){
        if (this.debugWindow){
            this.debugWindow.Println(msg)
        }
    }

}


class Debug_Gui{
    __new(){
        Gui +AlwaysOnTop
        Gui Add, Text,, Active window change detection log
        Gui Font,, Consolas
        Gui Add, Edit, HwndhLog xm w800 r30 ReadOnly -Wrap -WantReturn
        Gui show
        return this
    }
    GuiClose() {
        ExitApp
    }

    ; Prints a line to the logging edit box
    Println(s) {
        global hLog
        static MAX_LINES := 1000, LINE_ADJUST := 200, nLines := 0
        ; EM_SETSEL = 0xB1, EM_REPLACESEL = 0xC2, EM_LINEINDEX = 0xBB
        if (nLines = MAX_LINES) {
            ; Delete the oldest LINE_ADJUST lines
            SendMessage 0xBB, LINE_ADJUST,,, ahk_id %hLog%
            SendMessage 0xB1, 0, ErrorLevel,, ahk_id %hLog%
            SendMessage 0xC2, 0, 0,, ahk_id %hLog%
            nLines -= LINE_ADJUST
        }
        ++nLines
        ; Move to the end by selecting all and deselecting
        SendMessage 0xB1, 0, -1,, ahk_id %hLog%
        SendMessage 0xB1, -1, -1,, ahk_id %hLog%
        ; Add the line
        str := "[" A_Hour ":" A_Min "] " s "`r`n"
        SendMessage 0xC2, 0, &str,, ahk_id %hLog%
    }
}

