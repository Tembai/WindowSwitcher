#Requires AutoHotkey v2.0
#SingleInstance Force

; ===================================================================
; VIRTUAL DESKTOP NAVIGATION & WINDOW MOVEMENT
; ===================================================================
; Features:
; 1. Win+Number (1-9): Switch to desktop by number
; 2. Win+Tab/Shift+Tab: Switch to next/previous desktop
; 3. Win+` (backtick) or Ctrl+Win+Tab: Open Task View
; 4. Alt+Win+Left/Right: Move active window to adjacent desktop
; 5. Win+Shift+Number (1-9): Move active window to desktop without switching view
; 6. XButton1/XButton2 over taskbar: Switch desktops
; 7. Ctrl+XButton1/XButton2 over taskbar: Move active window to desktop
; 8. XButton1/XButton2 over window title bar: Move that window to desktop
; 9. XButton1+XButton2 anywhere: Open Task View
; 10. Win+Ctrl+0: Show desktop tracking status
; 
; Requires VirtualDesktopAccessor.dll for optimal performance and accuracy
; ===================================================================

; Global state variables for button detection
global xbutton1_down := false
global xbutton2_down := false
global action_fired := false

; Track current desktop number - use 0 to indicate "unknown"
global currentDesktop := 0
global hasVirtualDesktopAccessor := false

; Initialize VirtualDesktopAccessor.dll if available
InitializeVirtualDesktopAccessor()

; Add a hotkey to reset desktop tracking if it gets out of sync
; Win+Ctrl+0 to reset desktop tracking and show current status
#^0:: {
    global currentDesktop, hasVirtualDesktopAccessor
    
    if (hasVirtualDesktopAccessor) {
        ; Get accurate current desktop
        actualDesktop := GetCurrentDesktop()
        currentDesktop := actualDesktop
        desktopCount := GetDesktopCount()
        ToolTip("VirtualDesktopAccessor active - Current desktop: " . actualDesktop . "/" . desktopCount)
    } else {
        ; Reset to unknown state
        currentDesktop := 0
        ToolTip("VirtualDesktopAccessor not available - tracking reset")
    }
    
    SetTimer(() => ToolTip(), -3000)  ; Hide tooltip after 3 seconds
}

; ===================================================================
; KEYBOARD SHORTCUTS
; ===================================================================

; Alt+Win+Arrow to move windows
!#Left:: {
    MoveWindowToDesktop("Left")
}

!#Right:: {
    MoveWindowToDesktop("Right")
}

; Win+Tab to switch to next desktop
#Tab:: {
    global hasVirtualDesktopAccessor, currentDesktop
    SyncDesktopTracking()
    
    if (hasVirtualDesktopAccessor) {
        SwitchDesktop(currentDesktop + 1)
    } else {
        Send("#^{Right}")
    }
}

; Win+Shift+Tab to switch to previous desktop
#+Tab:: {
    global hasVirtualDesktopAccessor, currentDesktop
    SyncDesktopTracking()
    
    if (hasVirtualDesktopAccessor) {
        SwitchDesktop(currentDesktop - 1)
    } else {
        Send("#^{Left}")
    }
}

; Win+Number to switch to desktop by number
#1:: SwitchDesktop(1)
#2:: SwitchDesktop(2)
#3:: SwitchDesktop(3)
#4:: SwitchDesktop(4)
#5:: SwitchDesktop(5)
#6:: SwitchDesktop(6)
#7:: SwitchDesktop(7)
#8:: SwitchDesktop(8)
#9:: SwitchDesktop(9)

; Win+Shift+Number to move active window to desktop without switching view
#+1:: MoveWindowToDesktopNoSwitch(1)
#+2:: MoveWindowToDesktopNoSwitch(2)
#+3:: MoveWindowToDesktopNoSwitch(3)
#+4:: MoveWindowToDesktopNoSwitch(4)
#+5:: MoveWindowToDesktopNoSwitch(5)
#+6:: MoveWindowToDesktopNoSwitch(6)
#+7:: MoveWindowToDesktopNoSwitch(7)
#+8:: MoveWindowToDesktopNoSwitch(8)
#+9:: MoveWindowToDesktopNoSwitch(9)

; Win+` (backtick) to open Task View
#`:: {
    OpenTaskView()
}

; Ctrl+Win+Tab to open Task View
#^Tab:: {
    OpenTaskView()
}

; ===================================================================
; TASKBAR CONTEXT: Mouse side buttons for desktop switching
; ===================================================================

#HotIf MouseIsOverTaskbar()

XButton1:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton1_down := true
    action_fired := false
    
    KeyWait("XButton1")
    
    ; Check if both buttons were pressed together
    if (xbutton2_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    }
    else if (!action_fired) {
        global currentDesktop
        SyncDesktopTracking()
        
        targetDesktop := currentDesktop + 1
        maxDesktops := GetDesktopCount()
        
        if (maxDesktops > 0 && targetDesktop > maxDesktops) {
            ToolTip("Already on last desktop (" . maxDesktops . ")")
            SetTimer(() => ToolTip(), -1500)
        } else if (targetDesktop > 9) {
            ToolTip("Already on last desktop (9)")
            SetTimer(() => ToolTip(), -1500)
        } else {
            SwitchDesktop(targetDesktop)
        }
    }
    
    xbutton1_down := false
}

XButton2:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton2_down := true
    action_fired := false
    
    KeyWait("XButton2")
    
    ; Check if both buttons were pressed together
    if (xbutton1_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    }
    else if (!action_fired) {
        global currentDesktop
        SyncDesktopTracking()
        
        targetDesktop := currentDesktop - 1
        
        if (targetDesktop < 1) {
            ToolTip("Already on first desktop")
            SetTimer(() => ToolTip(), -1500)
        } else {
            SwitchDesktop(targetDesktop)
        }
    }
    
    xbutton2_down := false
}

; Ctrl+XButton combinations to move windows
^XButton1:: {
    MoveWindowToDesktop("Right")
}

^XButton2:: {
    MoveWindowToDesktop("Left")
}

#HotIf

; ===================================================================
; TITLE BAR CONTEXT: Mouse side buttons to move windows
; ===================================================================

#HotIf MouseIsOverTitleBar()

XButton1:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton1_down := true
    action_fired := false
    
    ; Get the window under mouse immediately
    MouseGetPos(, , &winID)
    
    KeyWait("XButton1")
    
    ; Check if both buttons pressed for Task View
    if (xbutton2_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    } else if (!action_fired) {
        ; Check if we can move right before attempting
        global currentDesktop
        SyncDesktopTracking()
        
        maxDesktops := GetDesktopCount()
        
        if (maxDesktops > 0 && currentDesktop >= maxDesktops) {
            ToolTip("Already on last desktop (" . maxDesktops . ")")
            SetTimer(() => ToolTip(), -1500)
        } else if (currentDesktop >= 9) {
            ToolTip("Already on last desktop (9)")
            SetTimer(() => ToolTip(), -1500)
        } else {
            ; Show brief feedback about which window is being moved
            try {
                winTitle := WinGetTitle("ahk_id " winID)
                if (StrLen(winTitle) > 50) {
                    winTitle := SubStr(winTitle, 1, 47) . "..."
                }
                ToolTip("Moving: " . winTitle . " →")
                SetTimer(() => ToolTip(), -1000)
            } catch {
                ToolTip("Moving window →")
                SetTimer(() => ToolTip(), -1000)
            }
            MoveSpecificWindowToDesktop(winID, "Right")
        }
    }
    
    xbutton1_down := false
}

XButton2:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton2_down := true
    action_fired := false
    
    ; Get the window under mouse immediately
    MouseGetPos(, , &winID)
    
    KeyWait("XButton2")
    
    ; Check if both buttons pressed for Task View
    if (xbutton1_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    } else if (!action_fired) {
        ; Check if we can move left before attempting
        global currentDesktop
        SyncDesktopTracking()
        
        if (currentDesktop <= 1) {
            ToolTip("Already on first desktop")
            SetTimer(() => ToolTip(), -1500)
        } else {
            ; Show brief feedback about which window is being moved
            try {
                winTitle := WinGetTitle("ahk_id " winID)
                if (StrLen(winTitle) > 50) {
                    winTitle := SubStr(winTitle, 1, 47) . "..."
                }
                ToolTip("Moving: " . winTitle . " ←")
                SetTimer(() => ToolTip(), -1000)
            } catch {
                ToolTip("Moving window ←")
                SetTimer(() => ToolTip(), -1000)
            }
            MoveSpecificWindowToDesktop(winID, "Left")
        }
    }
    
    xbutton2_down := false
}

#HotIf

; ===================================================================
; GLOBAL CONTEXT: XButton1+XButton2 anywhere opens Task View
; ===================================================================

#HotIf !MouseIsOverTaskbar() && !MouseIsOverTitleBar()

XButton1:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton1_down := true
    action_fired := false
    
    KeyWait("XButton1")
    
    if (xbutton2_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    }
    else if (!action_fired) {
        ; Pass through the button to its normal function
        Send("{XButton1}")
    }
    
    xbutton1_down := false
}

XButton2:: {
    global xbutton1_down, xbutton2_down, action_fired
    xbutton2_down := true
    action_fired := false
    
    KeyWait("XButton2")
    
    if (xbutton1_down && !action_fired) {
        OpenTaskView()
        action_fired := true
    }
    else if (!action_fired) {
        ; Pass through the button to its normal function
        Send("{XButton2}")
    }
    
    xbutton2_down := false
}

#HotIf

; ===================================================================
; HELPER FUNCTIONS
; ===================================================================

; Move a specific window to a different virtual desktop
MoveSpecificWindowToDesktop(hwnd, direction) {
    global hasVirtualDesktopAccessor, currentDesktop
    
    if (!hwnd) {
        return
    }
    
    ; Sync desktop tracking first
    SyncDesktopTracking()
    
    ; Use VirtualDesktopAccessor for clean window movement if available
    if (hasVirtualDesktopAccessor) {
        try {
            ; Calculate target desktop
            if (direction = "Left") {
                targetDesktop := currentDesktop - 1
                if (targetDesktop < 1) {
                    targetDesktop := 1
                    ToolTip("Already on first desktop")
                    SetTimer(() => ToolTip(), -1500)
                    return
                }
            } else {  ; Right
                targetDesktop := currentDesktop + 1
                maxDesktops := GetDesktopCount()
                if (maxDesktops > 0 && targetDesktop > maxDesktops) {
                    targetDesktop := maxDesktops
                    ToolTip("Already on last desktop")
                    SetTimer(() => ToolTip(), -1500)
                    return
                } else if (targetDesktop > 9) {
                    targetDesktop := 9
                }
            }
            
            ; Move the specific window to target desktop using DLL (0-based index)
            DllCall("VirtualDesktopAccessor.dll\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", targetDesktop - 1)
            
            ; Switch to that desktop to follow the window
            DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", targetDesktop - 1)
            
            ; Update our tracking
            currentDesktop := targetDesktop
            
            ; Ensure window has focus
            Sleep(50)
            WinActivate("ahk_id " hwnd)
            
            return
        } catch {
            ; DLL call failed, fall back to old method
            hasVirtualDesktopAccessor := false
        }
    }
    
    ; Fallback method: activate window first, then use keyboard shortcuts
    WinActivate("ahk_id " hwnd)
    Sleep(50)
    
    Send("{LWin down}{Ctrl down}{" direction "}{Ctrl up}{LWin up}")
    Sleep(150)
    
    ; Update tracking based on direction
    if (direction = "Left" && currentDesktop > 1) {
        currentDesktop--
    } else if (direction = "Right" && currentDesktop < 9) {
        currentDesktop++
    }
}

; Move the active window to a different virtual desktop
MoveWindowToDesktop(direction) {
    global hasVirtualDesktopAccessor, currentDesktop
    
    hwnd := WinActive("A")
    if (!hwnd) {
        return
    }
    
    ; Sync desktop tracking first
    SyncDesktopTracking()
    
    ; Store the current desktop before attempting move
    desktopBeforeMove := currentDesktop
    
    ; Use VirtualDesktopAccessor for clean window movement if available
    if (hasVirtualDesktopAccessor) {
        try {
            ; Calculate target desktop
            if (direction = "Left") {
                targetDesktop := currentDesktop - 1
                if (targetDesktop < 1) {
                    targetDesktop := 1
                    ToolTip("Already on first desktop")
                    SetTimer(() => ToolTip(), -1500)
                    return
                }
            } else {  ; Right
                targetDesktop := currentDesktop + 1
                maxDesktops := GetDesktopCount()
                if (maxDesktops > 0 && targetDesktop > maxDesktops) {
                    targetDesktop := maxDesktops
                    ToolTip("Already on last desktop")
                    SetTimer(() => ToolTip(), -1500)
                    return
                } else if (targetDesktop > 9) {
                    targetDesktop := 9
                }
            }
            
            ; Try to move window to target desktop using DLL (0-based index)
            DllCall("VirtualDesktopAccessor.dll\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", targetDesktop - 1)
            
            ; Switch to that desktop to follow the window
            DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", targetDesktop - 1)
            
            ; Update our tracking
            currentDesktop := targetDesktop
            
            ; Ensure window has focus
            Sleep(50)
            WinActivate("ahk_id " hwnd)
            
            return
        } catch {
            ; DLL call failed, fall back to old method
            hasVirtualDesktopAccessor := false
        }
    }
    
    ; Fallback method: use keyboard shortcuts
    ; This method doesn't reliably indicate if move failed, so we switch desktop regardless
    Send("{LWin down}{Ctrl down}{" direction "}{Ctrl up}{LWin up}")
    Sleep(150)
    
    ; Update tracking based on direction
    if (direction = "Left" && currentDesktop > 1) {
        currentDesktop--
    } else if (direction = "Right" && currentDesktop < 9) {
        currentDesktop++
    }
    
    ; Ensure window has focus
    WinActivate("ahk_id " hwnd)
}

; Move window to specific desktop without switching view
MoveWindowToDesktopNoSwitch(targetDesktop) {
    global hasVirtualDesktopAccessor, currentDesktop
    
    hwnd := WinActive("A")
    if (!hwnd) {
        return
    }
    
    ; Validate target desktop number
    if (targetDesktop < 1 || targetDesktop > 9) {
        return
    }
    
    ; Sync desktop tracking first
    SyncDesktopTracking()
    
    ; Use VirtualDesktopAccessor for clean window movement if available
    if (hasVirtualDesktopAccessor) {
        try {
            maxDesktops := GetDesktopCount()
            if (maxDesktops > 0 && targetDesktop > maxDesktops) {
                ToolTip("Desktop " . targetDesktop . " does not exist")
                SetTimer(() => ToolTip(), -1500)
                return
            }
            
            ; Move window to target desktop using DLL (0-based index)
            ; Don't switch desktops - just move the window
            DllCall("VirtualDesktopAccessor.dll\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", targetDesktop - 1)
            
            ; Show confirmation tooltip
            ToolTip("Window moved to desktop " . targetDesktop)
            SetTimer(() => ToolTip(), -1500)
            
            return
        } catch {
            ; DLL call failed, fall back to old method
            hasVirtualDesktopAccessor := false
        }
    }
    
    ; Fallback method: temporarily switch, move window, then switch back
    ; This is less elegant but works without VirtualDesktopAccessor.dll
    originalDesktop := currentDesktop
    
    ; Switch to target desktop
    SwitchDesktop(targetDesktop)
    Sleep(100)
    
    ; Move window using keyboard shortcut
    Send("{LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}")
    Sleep(50)
    
    ; Switch back to original desktop
    if (originalDesktop > 0 && originalDesktop != targetDesktop) {
        SwitchDesktop(originalDesktop)
    }
    
    ToolTip("Window moved to desktop " . targetDesktop)
    SetTimer(() => ToolTip(), -1500)
}

; Simple desktop switching function
SwitchDesktop(targetDesktop) {
    global hasVirtualDesktopAccessor, currentDesktop
    
    SyncDesktopTracking()
    
    if (hasVirtualDesktopAccessor && targetDesktop > 0 && targetDesktop <= 9) {
        try {
            DllCall("VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", targetDesktop - 1)
            currentDesktop := targetDesktop
            
            ; Activate the topmost window on the new desktop
            Sleep(100)  ; Give desktop switch time to complete
            ActivateTopmostWindow()
            return
        } catch {
            hasVirtualDesktopAccessor := false
        }
    }
    
    ; Fallback to keyboard shortcuts
    if (targetDesktop > 0 && targetDesktop <= 9) {
        Send("#^{Home}")  ; Go to first desktop
        Loop (targetDesktop - 1) {
            Send("#^{Right}")
            Sleep(30)
        }
        currentDesktop := targetDesktop
        
        ; Activate the topmost window on the new desktop
        Sleep(150)  ; Give desktop switch time to complete
        ActivateTopmostWindow()
    }
}

; Activate the topmost visible window on current desktop
ActivateTopmostWindow() {
    try {
        ; Get the foreground window
        hwnd := DllCall("GetForegroundWindow", "Ptr")
        
        ; If no foreground window or it's the desktop, find a suitable window
        if (!hwnd || WinGetClass("ahk_id " hwnd) = "Progman" || WinGetClass("ahk_id " hwnd) = "WorkerW") {
            ; Get list of all windows
            windows := WinGetList()
            
            for hwndTest in windows {
                ; Skip if window is not visible
                if (!IsWindow(hwndTest) || !WinExist("ahk_id " hwndTest)) {
                    continue
                }
                
                ; Get window class and title
                try {
                    winClass := WinGetClass("ahk_id " hwndTest)
                    winTitle := WinGetTitle("ahk_id " hwndTest)
                } catch {
                    continue
                }
                
                ; Skip system windows, taskbar, etc.
                if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd" || 
                    winClass = "Progman" || winClass = "WorkerW" || winClass = "DV2ControlHost" ||
                    winTitle = "" || InStr(winClass, "Windows.UI.Core.CoreWindow")) {
                    continue
                }
                
                ; Check if window is actually visible (not minimized)
                try {
                    winState := WinGetMinMax("ahk_id " hwndTest)
                    if (winState = -1) {  ; Window is minimized
                        continue
                    }
                } catch {
                    continue
                }
                
                ; Found a suitable window, activate it
                try {
                    WinActivate("ahk_id " hwndTest)
                    WinWaitActive("ahk_id " hwndTest, , 1)  ; Wait up to 1 second
                    return
                } catch {
                    continue
                }
            }
        } else {
            ; Foreground window exists, just ensure it's properly activated
            WinActivate("ahk_id " hwnd)
        }
    } catch {
        ; If all else fails, try to activate any visible window
        try {
            WinActivate("A")
        } catch {
            ; Do nothing if activation fails
        }
    }
}

; Check if a window handle is valid
IsWindow(hwnd) {
    return DllCall("IsWindow", "Ptr", hwnd)
}

; Open Windows Task View
OpenTaskView() {
    Send("{LWin down}{Tab down}")
    Sleep(250)
    Send("{Tab up}{LWin up}")
}

; Initialize VirtualDesktopAccessor.dll
InitializeVirtualDesktopAccessor() {
    global hasVirtualDesktopAccessor
    
    try {
        ; Try to load the DLL and test if it works
        ; The DLL should be in the same folder as the script or in PATH
        testResult := DllCall("VirtualDesktopAccessor.dll\GetCurrentDesktopNumber", "Int")
        hasVirtualDesktopAccessor := true
        
        ; No continuous monitoring - use event-based detection only
        ; This eliminates all background CPU usage
        
        ToolTip("VirtualDesktopAccessor.dll loaded - Event-based detection active (zero CPU overhead)!")
        SetTimer(() => ToolTip(), -3000)
        
    } catch as e {
        hasVirtualDesktopAccessor := false
        ToolTip("VirtualDesktopAccessor.dll not found - using fallback method")
        SetTimer(() => ToolTip(), -3000)
    }
}

; Get current desktop number using VirtualDesktopAccessor.dll
GetCurrentDesktop() {
    global hasVirtualDesktopAccessor
    
    if (hasVirtualDesktopAccessor) {
        try {
            ; Get current desktop number (0-based, so add 1 to make it 1-based)
            return DllCall("VirtualDesktopAccessor.dll\GetCurrentDesktopNumber", "Int") + 1
        } catch {
            ; DLL call failed, fall back to unknown
            hasVirtualDesktopAccessor := false
            return -1
        }
    }
    
    ; Fallback: return -1 to indicate unknown
    return -1
}

; Sync desktop tracking on-demand (event-based, zero background CPU)
SyncDesktopTracking() {
    global currentDesktop, hasVirtualDesktopAccessor
    
    if (!hasVirtualDesktopAccessor) {
        return false
    }
    
    try {
        actualDesktop := GetCurrentDesktop()
        if (actualDesktop > 0) {
            currentDesktop := actualDesktop
            return true
        }
    } catch {
        ; DLL call failed, disable VirtualDesktopAccessor
        hasVirtualDesktopAccessor := false
    }
    
    return false
}

; Get total number of desktops
GetDesktopCount() {
    global hasVirtualDesktopAccessor
    
    if (hasVirtualDesktopAccessor) {
        try {
            return DllCall("VirtualDesktopAccessor.dll\GetDesktopCount", "Int")
        } catch {
            hasVirtualDesktopAccessor := false
        }
    }
    
    return -1  ; Unknown
}

; Check if mouse cursor is over a specific window
MouseIsOver(winTitle) {
    MouseGetPos(, , &winID)
    return WinExist(winTitle " ahk_id " winID)
}

; Check if mouse cursor is over any taskbar (primary or secondary monitors)
MouseIsOverTaskbar() {
    MouseGetPos(, , &winID)
    if (!winID) {
        return false
    }
    
    ; Check for primary taskbar
    if (WinExist("ahk_class Shell_TrayWnd ahk_id " winID)) {
        return true
    }
    
    ; Check for secondary taskbars (Windows 10/11 multi-monitor)
    if (WinExist("ahk_class Shell_SecondaryTrayWnd ahk_id " winID)) {
        return true
    }
    
    ; Alternative check: get window class directly
    try {
        winClass := WinGetClass("ahk_id " winID)
        if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd") {
            return true
        }
    } catch {
        return false
    }
    
    return false
}

; Check if mouse cursor is over a window title bar or top area
MouseIsOverTitleBar() {
    MouseGetPos(&mouseX, &mouseY, &winID)
    
    ; Not over any window or over any taskbar
    if (!winID || MouseIsOverTaskbar()) {
        return false
    }
    
    ; Get window position and size
    try {
        WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " winID)
    } catch {
        return false
    }
    
    ; Calculate relative position within window
    relY := mouseY - winY
    relX := mouseX - winX
    
    ; Check bounds first
    if (relY < 0 || relX < 0 || relX > winW) {
        return false
    }
    
    ; Check if window is maximized
    try {
        winStyle := WinGetStyle("ahk_id " winID)
        isMaximized := (winStyle & 0x01000000)  ; WS_MAXIMIZE
    } catch {
        isMaximized := false
    }
    
    ; Get window class for special handling
    try {
        winClass := WinGetClass("ahk_id " winID)
        winTitle := WinGetTitle("ahk_id " winID)
        
        ; Browser detection with expanded sizing
        if (InStr(winClass, "Chrome") || InStr(winClass, "Firefox") || InStr(winClass, "Edge") ||
            InStr(winClass, "MozillaWindowClass") ||
            InStr(winTitle, "Chrome") || InStr(winTitle, "Firefox") || InStr(winTitle, "Edge")) {
            
            ; Browsers: Increase to 140px to catch all tab areas reliably
            browserTopHeight := isMaximized ? 120 : 140
            return (relY <= browserTopHeight)
        }
        
        ; Modern Windows apps - be more generous
        if (InStr(winClass, "ApplicationFrameWindow") || InStr(winClass, "Windows.UI")) {
            ; Modern apps: Increase to 120px
            return (relY <= 120)
        }
        
        ; VS Code and similar developer tools
        if (InStr(winTitle, "Visual Studio Code") || InStr(winTitle, "Code") ||
            InStr(winClass, "Chrome_WidgetWin_1")) {
            return (relY <= 100)
        }
        
    } catch {
        ; Continue with fallback detection
    }
    
    ; Standard windows: Be more generous - increase from 60/80 to 100/120
    ; This should catch more edge cases where detection fails
    standardTopHeight := isMaximized ? 100 : 120
    
    return (relY <= standardTopHeight)
}