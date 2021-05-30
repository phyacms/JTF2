; JTF2: Joint-Trouble-Free for TD2
; A macro application for Tom Clancy's Division® 2 agents

#SingleInstance Force
#NoEnv

; App information
Global AppName := "JTF2: Joint-Trouble-Free for TD2"
Global AppNameShort := "JTF2"
Global AppIconPath := "JTF2.ico"
Global Version := "0.0.1"
Global RepositoryLink = "https://github.com/phyacms/JTF2"
Global GameProcessName = "TheDivision2.exe"
Global LaunchCommand = "uplay://launch/4932/0"

; Window dimension
Global WindowWidth := 540
Global Window24 := 272
Global HorizontalMargin := 8
Global VerticalMargin := 4

; Setting limits
Global IntervalMinimum := 50
Global IntervalMaximum := 10000

; Global constants
Global AutoClickModeNamePress := "PressMode"
Global AutoClickModeNameRepeat := "RepeatMode"

; Global variables
Global bGameProcessDetectedOnce := False
Global bGameProcessDetected := False
Global bGameProcessFocused := False
Global bEditing := False
Global AutoClickInterval := IntervalMinimum
Global CurrentAutoClickMode
Global bAutoClicking := False

; Entry
AppMain()
Return

;===============================================================

GuiClose:
AppExit()

; Main function
AppMain()
{
    SetWorkingDir %A_ScriptDir%
    SetBatchLines -1

    Menu, Tray, Icon, %AppIconPath%, 1, 1

    CreateGuiControls()

    OnGameProcessLost()
    DetectGameProcess()
}

AppExit()
{
	SetTimer, Timer_DetectGameProcess, Off
    FinishAutoClick()
    ExitApp
}

;===============================================================

; Gui controls
Global HKToggleActivation
Global HKToggleAutoClick
Global HKRotateAutoClickMode
Global HKAlterClickKey
Global HKRunOpenInventoryCacheMacro
Global HKRunOpenApparelCacheMacro
Global HKRunSummitEvMacro
Global TxtGameProcDetect
Global TxtClickPerSec
Global TxtRPM
Global BtnHelp
Global BtnEdit
Global EBInterval
Global RadioAutoClickPressMode
Global RadioAutoClickRepeatMode
Global CBActivate
Global CBToggleAutoClick
Global CBToggleAutoClickModeByHotkey
Global CBUseAlterClickKey
Global CBRunOpenInventoryCacheMacro
Global CBRunOpenApparelCacheMacro
Global CBRunSummitEvMacro
Global CBCloseOnGameExit
Global SBStatus

; Gui events

EventBtnRun:
Run %LaunchCommand%
Return

EventBtnHelp:
Run %RepositoryLink%
Return

EventBtnEdit:
ToggleEditMode()
Return

EventBtnSetToDefault:
SetupGuiControls(True)
ApplySettings()
Return

EventBtnClose:
AppExit()
Return

EventUserChangedGuiControl:
ApplySettings()
Return

; Hotkey events

HKToggleActivation:
GuiControlGet, bChk,, CBActivate
If bChk
    GuiControl,, CBActivate, 0
Else
    GuiControl,, CBActivate, 1
ApplySettings()
Return

HKToggleAutoClick:
GuiControlGet, bChk,, CBToggleAutoClick
If bChk
    GuiControl,, CBToggleAutoClick, 0
Else
    GuiControl,, CBToggleAutoClick, 1
ApplySettings()
Return

HKRotateAutoClickMode:
GuiControlGet, bPressMode,, RadioAutoClickPressMode
GuiControlGet, bRepeatMode,, RadioAutoClickRepeatMode
If bPressMode
{
    GuiControl,, RadioAutoClickRepeatMode, 1
}
Else If bRepeatMode
{
    GuiControl,, RadioAutoClickPressMode, 1
}
ApplySettings()
Return

HKAlterClickKey:
GuiControlGet, bChk,, CBUseAlterClickKey
If bChk
{
    OnClick()
}
Return

HKRunOpenInventoryCacheMacro:
HKRunOpenApparelCacheMacro:
HKRunSummitEvMacro:
; @WIP
MsgBox, RunMacro Occured
Return

; Key events

~LButton::
OnClick()
Return

; Functions

CreateGuiControls()
{
    Gui Add, CheckBox, x8 y4 w60 h20 vCBActivate gEventUserChangedGuiControl, Activate
    Gui Add, Hotkey, x72 y4 w84 h20 vHKToggleActivation
    Gui Add, Text, x402 y7 w60 h20 vTxtGameProcDetect, {ProcDetect}
    Gui Add, Button, x470 y4 w48 h20 gEventBtnRun, Run
    Gui Add, Button, x518 y4 w18 h20 vBtnHelp gEventBtnHelp, ?

    Gui Add, GroupBox, x8 y32 w324 h212, Auto-Click
    Gui Add, CheckBox, x20 y52 w120 h20 vCBToggleAutoClick gEventUserChangedGuiControl, Enable Auto-Click
    Gui Add, Text, x20 y74 w120 h20 +0x200, Toggle Enability
    Gui Add, Hotkey, x142 y74 w84 h20 vHKToggleAutoClick
    Gui Add, Text, x20 y96 w120 h20 +0x200, Interval
    Gui Add, Edit, x142 y96 w52 h20 +Number vEBInterval, {Intv}
    Gui Add, Text, x200 y96 w24 h20 +0x200, ms
    Gui Add, Text, x240 y96 w84 h20 +0x200, (%IntervalMinimum% - %IntervalMaximum% ms)
    Gui Add, Text, x142 y118 w32 h20 +0x200 vTxtClickPerSec, {CPS}
    Gui Add, Text, x180 y118 w48 h20 +0x200, Click/s
    Gui Add, Text, x222 y118 w20 h20 +0x200, ⇒
    Gui Add, Text, x240 y118 w48 h20 +0x200 vTxtRPM, {RPM}
    Gui Add, Text, x288 y118 w48 h20 +0x200, RPM
    Gui Add, Text, x20 y142 w120 h20 +0x200, Mode
    Gui Add, Radio, x142 y142 w120 h20 vRadioAutoClickPressMode gEventUserChangedGuiControl, Press to Auto-Click
    Gui Add, Radio, x142 y160 w120 h20 vRadioAutoClickRepeatMode gEventUserChangedGuiControl, On/Off Repeat
    Gui Add, CheckBox, x20 y188 w120 h20 vCBToggleAutoClickModeByHotkey gEventUserChangedGuiControl, Toggle Mode by
    Gui Add, Hotkey, x142 y188 w84 h20 vHKRotateAutoClickMode
    Gui Add, CheckBox, x20 y210 w120 h20 vCBUseAlterClickKey, Use Alternative Key
    Gui Add, Hotkey, x142 y210 w84 h20 vHKAlterClickKey

    Gui Add, GroupBox, x336 y32 w200 h76, Auto-Open Cache
    Gui Add, CheckBox, x352 y52 w84 h20 vCBRunOpenInventoryCacheMacro gEventUserChangedGuiControl, Inventory
    Gui Add, Hotkey, x440 y52 w24 w84 vHKRunOpenInventoryCacheMacro
    Gui Add, CheckBox, x352 y74 w84 h20 vCBRunOpenApparelCacheMacro gEventUserChangedGuiControl, Apparel
    Gui Add, Hotkey, x440 y74 w24 w84 vHKRunOpenApparelCacheMacro

    Gui Add, GroupBox, x336 y112 w200 h54, Other Macros
    Gui Add, CheckBox, x352 y132 w84 h20 vCBRunSummitEvMacro gEventUserChangedGuiControl, Summit Ev.
    Gui Add, Hotkey, x440 y132 w24 w84 vHKRunSummitEvMacro

    Gui Add, CheckBox, x338 y192 w120 h20 vCBCloseOnGameExit, Close on game exit
    Gui Add, Button, x336 y212 w64 h32 vBtnEdit gEventBtnEdit, {Edit}
    Gui Add, Button, x400 y212 w52 h32 gEventBtnSetToDefault, Set to Default
    Gui Add, Button, x472 y212 w64 h32 gEventBtnClose, Close

    VersionTxt := " v" + Version
    Gui Add, StatusBar, vSBStatus, %VersionTxt%

    SetupGuiControls(False)
    ApplySettings()

    GuiControl, Focus, BtnHelp
    Gui Show, w%WindowWidth% h%Window24%, %AppName%

    Return
}

SetupGuiControls(bUseDefault)
{
    GuiControl,, HKToggleActivation, ``
    GuiControl,, HKToggleAutoClick, XButton1
    GuiControl,, HKRotateAutoClickMode, !C
    GuiControl,, HKAlterClickKey, C
    GuiControl,, HKRunOpenInventoryCacheMacro, F9
    GuiControl,, HKRunOpenApparelCacheMacro, F10
    GuiControl,, HKRunSummitEvMacro, F11

    GuiControl,, EBInterval, %IntervalMinimum%
    GuiControl,, RadioAutoClickPressMode, 1
    GuiControl,, CBToggleAutoClick, 0
    GuiControl,, CBToggleAutoClickModeByHotkey, 0
    GuiControl,, CBUseAlterClickKey, 0
    GuiControl,, CBRunOpenInventoryCacheMacro, 1
    GuiControl,, CBRunOpenApparelCacheMacro, 1
    GuiControl,, CBRunSummitEvMacro, 0
    GuiControl,, CBCloseOnGameExit, 1
}

UpdateGuiControls()
{
    If IsEditing()
    {
        GuiControl,, BtnEdit, Done

        GuiControl, Enabled, HKToggleActivation
        GuiControl, Enabled, HKToggleAutoClick
        GuiControl, Enabled, HKRotateAutoClickMode
        GuiControl, Enabled, HKAlterClickKey
        GuiControl, Enabled, HKRunOpenInventoryCacheMacro
        GuiControl, Enabled, HKRunOpenApparelCacheMacro
        GuiControl, Enabled, HKRunSummitEvMacro
        GuiControl, Enabled, EBInterval
    }
    Else
    {
        GuiControl,, BtnEdit, Edit

        GuiControl, Disabled, HKToggleActivation
        GuiControl, Disabled, HKToggleAutoClick
        GuiControl, Disabled, HKRotateAutoClickMode
        GuiControl, Disabled, HKAlterClickKey
        GuiControl, Disabled, HKRunOpenInventoryCacheMacro
        GuiControl, Disabled, HKRunOpenApparelCacheMacro
        GuiControl, Disabled, HKRunSummitEvMacro
        GuiControl, Disabled, EBInterval
    }

    ; @WIP
}

;===============================================================

ToggleEditMode()
{
    SetEditMode(!bEditing)
}

SetEditMode(bEdit)
{
    If bEditing != bEdit
    {
        bEditing := bEdit
        If bEdit
        {
            UpdateGuiControls()
        }
        Else
        {
            ApplySettings()
        }
    }
}

IsEditing()
{
    Return bEditing
}

ApplySettings()
{
    FinishAutoClick()

    GuiControlGet, Interval,, EBInterval
    SetAutoClickInterval(Interval)

    GuiControlGet, bPressMode,, RadioAutoClickPressMode
    GuiControlGet, bRepeatMode,, RadioAutoClickRepeatMode
    If bPressMode
    {
        AutoClickMode := AutoClickModeNamePress
    }
    Else If bRepeatMode
    {
        AutoClickMode := AutoClickModeNameRepeat
    }
    SetAutoClickMode(AutoClickMode)

    ResetHotkeyBindings()
}

;===============================================================

Timer_DetectGameProcess:
RunDetectGameProcess()
Return

DetectGameProcess()
{
    SetTimer, Timer_DetectGameProcess, 100
}

RunDetectGameProcess()
{
    Process, Exist, %GameProcessName%
    ErrLv := ErrorLevel
    bDetected := ErrLv != 0
    If bGameProcessDetected != %bDetected%
    {
        bGameProcessDetected := bDetected
        If bDetected
        {
            OnGameProcessDetected()
        }
        Else
        {
            OnGameProcessLost()
        }
        UpdateGuiControls()
    }

    If bGameProcessDetected
    {
        WinGet, ActiveProc, ProcessName, A
        bFocused := ActiveProc = GameProcessName
        If bGameProcessFocused != %bFocused%
        {
            bGameProcessFocused := bFocused
            If bFocused
            {
                ; OnGameProcessFocused()
            }
            Else
            {
                ; OnGameProcessFocusLost()
                FinishAutoClick()
            }
            ResetHotkeyBindings()
        }
    }
}

OnGameProcessDetected()
{
    bGameProcessDetectedOnce := True

    GuiControl, Move, TxtGameProcDetect, x348 y7 w120 h20
    GuiControl, +cEF6C00, TxtGameProcDetect
    GuiControl,, TxtGameProcDetect, SHD Network Detected
}

OnGameProcessLost()
{
    FinishAutoClick()

    GuiControlGet, bCloseOnGameExit,, CBCloseOnGameExit
    If IsGameProcessDetectedOnce() && bCloseOnGameExit
    {
        AppExit()
        Return
    }

    GuiControl, Move, TxtGameProcDetect, x404 y7 w60 h20
    GuiControl, +cD80100, TxtGameProcDetect
    GuiControl,, TxtGameProcDetect, ISAC Offline
}

IsGameProcessDetectedOnce()
{
    Return bGameProcessDetectedOnce
}

IsGameProcessDetected()
{
    Return bGameProcessDetected
}

IsGameProcessFocused()
{
    Return bGameProcessFocused
}

;===============================================================

IsActivated()
{
    GuiControlGet, bActivated,, CBActivate
    Return bActivated
}

;===============================================================

ResetHotkeyBindings()
{
    UnbindAllHotkeyBindings()
    Gui, Submit, NoHide
    BindHotkeyBindingsConditional()
    UpdateGuiControls()
}

BindHotkeyBindingsConditional()
{
    If IsGameProcessFocused()
    {
        If Not !HKToggleActivation
        {
            Hotkey, %HKToggleActivation%, HKToggleActivation, On
        }

        If IsActivated()
        {
            If Not !HKToggleAutoClick
            {
                Hotkey, %HKToggleAutoClick%, HKToggleAutoClick, On
            }

            GuiControlGet, bChk,, CBToggleAutoClickModeByHotkey
            If bChk && Not !HKRotateAutoClickMode
            {
                Hotkey, %HKRotateAutoClickMode%, HKRotateAutoClickMode, On
            }
            GuiControlGet, bChk,, CBUseAlterClickKey
            If bChk && Not !HKAlterClickKey
            {
                Hotkey, %HKAlterClickKey%, HKAlterClickKey, On
            }

            GuiControlGet, bChk,, CBRunOpenInventoryCacheMacro
            If bChk && Not !HKRunOpenInventoryCacheMacro
            {
                Hotkey, %HKRunOpenInventoryCacheMacro%, HKRunOpenInventoryCacheMacro, On
            }
            GuiControlGet, bChk,, CBRunOpenApparelCacheMacro
            If bChk && Not !HKRunOpenApparelCacheMacro
            {
                Hotkey, %HKRunOpenApparelCacheMacro%, HKRunOpenApparelCacheMacro, On
            }

            GuiControlGet, bChk,, CBRunSummitEvMacro
            If bChk && Not !HKRunSummitEvMacro
            {
                Hotkey, %HKRunSummitEvMacro%, HKRunSummitEvMacro, On
            }
        }
    }
}

UnbindAllHotkeyBindings()
{
    If Not !HKToggleActivation
    {
        Hotkey, %HKToggleActivation%, HKToggleActivation, Off
    }
    If Not !HKToggleAutoClick
    {
        Hotkey, %HKToggleAutoClick%, HKToggleAutoClick, Off
    }
    If Not !HKRotateAutoClickMode
    {
        Hotkey, %HKRotateAutoClickMode%, HKRotateAutoClickMode, Off
    }
    If Not !HKAlterClickKey
    {
        Hotkey, %HKAlterClickKey%, HKAlterClickKey, Off
    }
    If Not !HKRunOpenInventoryCacheMacro
    {
        Hotkey, %HKRunOpenInventoryCacheMacro%, HKRunOpenInventoryCacheMacro, Off
    }
    If Not !HKRunOpenApparelCacheMacro
    {
        Hotkey, %HKRunOpenApparelCacheMacro%, HKRunOpenApparelCacheMacro, Off
    }
    If Not !HKRunSummitEvMacro
    {
        Hotkey, %HKRunSummitEvMacro%, HKRunSummitEvMacro, Off
    }
}

;===============================================================

SetAutoClickInterval(Interval)
{
    If Interval < %IntervalMinimum%
    {
        Interval := IntervalMinimum
    }
    If Interval > %IntervalMaximum%
    {
        Interval := IntervalMaximum
    }

    If AutoClickInterval != Interval
    {
        AutoClickInterval := Interval
        OnAutoClickIntervalChanged()
    }
}

OnAutoClickIntervalChanged()
{
    RPM := 60.0 * 1000.0 / AutoClickInterval
    RPMStr := Format("{1:0.2f}", RPM)
    ClickPerSec := RPM / 60.0
    ClickPerSecStr := Format("{1:0.2f}", ClickPerSec)
    GuiControl,, TxtClickPerSec, %ClickPerSecStr%
    GuiControl,, TxtRPM, %RPMStr%
}

;===============================================================

SetAutoClickMode(AutoClickMode)
{
    FinishAutoClick()

    If CurrentAutoClickMode != AutoClickMode
    {
        CurrentAutoClickMode := AutoClickMode
        ; OnAutoClickModeChanged()
    }
}

;===============================================================

Timer_AutoClick:
RunClick()
Return

IsAutoClickEnabled()
{
    GuiControlGet, bEnabled,, CBToggleAutoClick
    Return bEnabled
}

IsAutoClicking()
{
    Return bAutoClicking
}

StartAutoClick()
{
    bAutoClicking := True
    SetTimer, Timer_AutoClick, %AutoClickInterval%
    RunClick()
}

FinishAutoClick()
{
    bAutoClicking := False
    SetTimer, Timer_AutoClick, Off
}

OnClick()
{
    If IsGameProcessFocused() && IsActivated() && IsAutoClickEnabled()
    {
        If (CurrentAutoClickMode = AutoClickModeNamePress)
        {
            StartAutoClick()
            Return
        }
        Else If (CurrentAutoClickMode = AutoClickModeNameRepeat)
        {
            If (!IsAutoClicking())
            {
                StartAutoClick()
                Return
            }
        }
    }
    FinishAutoClick()
}

RunClick()
{
    If IsGameProcessFocused() && IsActivated() && IsAutoClickEnabled()
    {
        GuiControlGet, bAlterKeyAllowed,, CBUseAlterClickKey
        bKeyDown
            := GetKeyState("LButton", "P")
            || (bAlterKeyAllowed && GetKeyState(HKAlterClickKey, "P"))
        bClick
            := CurrentAutoClickMode = AutoClickModeNameRepeat
            || (CurrentAutoClickMode = AutoClickModeNamePress && bKeyDown)
        If (bClick)
        {
            Click
            Return
        }
    }
    FinishAutoClick()
}
