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

    DetectGameProcess()
}

AppExit()
{
    ExitApp
}

;===============================================================

; Gui controls
Global HKToggleActivation
Global HKToggleAC
Global HKRotateACMode
Global HKAlterClickKey
Global HKRunOpenInvCacheMacro
Global HKRunOpenApparelCacheMacro
Global HKRunSummitElevatorMacro
Global TxtGameProcDetect
Global TxtClickPerSec
Global TxtRPM
Global BtnHelp
Global BtnEdit
Global EBInterval
Global SBStatus

; Global variables
Global bGameProcessDetected := False
Global bGameProcessFocused := False
Global bEditing := True
Global AutoClickInterval := IntervalMinimum

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

EventBtnClose:
AppExit()
Return

CreateGuiControls()
{
    Gui Add, CheckBox, x8 y4 w60 h20, Activate
    Gui Add, Hotkey, x72 y4 w84 h20 vHKToggleActivation
    Gui Add, Text, x402 y7 w60 h20 vTxtGameProcDetect, {ProcDetect}
    Gui Add, Button, x470 y4 w48 h20 gEventBtnRun, Run
    Gui Add, Button, x518 y4 w18 h20 vBtnHelp gEventBtnHelp, ?

    Gui Add, GroupBox, x8 y32 w324 h212, Auto-Click
    Gui Add, CheckBox, x20 y52 w120 h20, Enable Auto-Click
    Gui Add, Text, x20 y74 w120 h20 +0x200, Toggle Enability
    Gui Add, Hotkey, x142 y74 w84 h20 vHKToggleAC
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
    Gui Add, Radio, x142 y142 w120 h20, Press to Auto-Click
    Gui Add, Radio, x142 y160 w120 h20, On/Off Repeat
    Gui Add, CheckBox, x20 y188 w120 h20, Toggle Mode by
    Gui Add, Hotkey, x142 y188 w84 h20 vHKRotateACMode
    Gui Add, CheckBox, x20 y210 w120 h20, Use Alternative Key
    Gui Add, Hotkey, x142 y210 w84 h20 vHKAlterClickKey

    Gui Add, GroupBox, x336 y32 w200 h76, Auto-Open Cache
    Gui Add, CheckBox, x352 y52 w84 h20, Inventory
    Gui Add, Hotkey, x440 y52 w24 w84 vHKRunOpenInvCacheMacro
    Gui Add, CheckBox, x352 y74 w84 h20, Apparel
    Gui Add, Hotkey, x440 y74 w24 w84 vHKRunOpenApparelCacheMacro

    Gui Add, GroupBox, x336 y112 w200 h54, Other Macros
    Gui Add, CheckBox, x352 y132 w84 h20, Summit Ev.
    Gui Add, Hotkey, x440 y132 w24 w84 vHKRunSummitElevatorMacro

    Gui Add, CheckBox, x338 y192 w120 h20, Close on game exit
    Gui Add, Button, x336 y212 w64 h32 vBtnEdit gEventBtnEdit, {Edit}
    Gui Add, Button, x400 y212 w52 h32, Set to Default
    Gui Add, Button, x472 y212 w64 h32 gEventBtnClose, Close

    VersionTxt := " v" + Version
    Gui Add, StatusBar, vSBStatus, %VersionTxt%

    SetupGuiControls()
    SetEditMode(False)

    UpdateGuiControls()
    GuiControl, Focus, BtnHelp

    Gui Show, w%WindowWidth% h%Window24%, %AppName%

    Return
}

SetupGuiControls()
{
    GuiControl,, HKToggleActivation, ``
    GuiControl,, HKToggleAC, XButton1
    GuiControl,, HKRotateACMode, !C
    GuiControl,, HKAlterClickKey, C
    GuiControl,, HKRunOpenInvCacheMacro, F9
    GuiControl,, HKRunOpenApparelCacheMacro, F10
    GuiControl,, HKRunSummitElevatorMacro, F11
    GuiControl,, EBInterval, %IntervalMinimum%
}

UpdateGuiControls()
{
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
            EditSettings()
        }
        Else
        {
            ApplySettings()
        }
        UpdateGuiControls()
    }
}

IsEditing()
{
    Return bEditing
}

EditSettings()
{
    GuiControl,, BtnEdit, Done
}

ApplySettings()
{
    GuiControl,, BtnEdit, Edit

    Gui, Submit, NoHide

    GuiControlGet, Interval,, EBInterval
    SetAutoClickInterval(Interval)
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
    bUpdateGuiControls := False

    Process, Exist, %GameProcessName%
    ErrLv := ErrorLevel
    bDetected := ErrLv != 0
    If bGameProcessDetected != bDetected
    {
        bGameProcessDetected := bDetected
        If bDetected
        {
            ; OnGameProcessDetected()
            GuiControl, Move, TxtGameProcDetect, x348 y7 w120 h20
            GuiControl, +cEF6C00, TxtGameProcDetect
            GuiControl,, TxtGameProcDetect, SHD Network Detected
        }
        Else
        {
            ; OnGameProcessLost()
            GuiControl, Move, TxtGameProcDetect, x404 y7 w60 h20
            GuiControl, +cD80100, TxtGameProcDetect
            GuiControl,, TxtGameProcDetect, ISAC Offline
        }
        bUpdateGuiControls := True
    }

    If bGameProcessDetected
    {
        WinGet, ActiveProc, ProcessName, A
        bFocused := ActiveProc = GameProcessName
        If bGameProcessFocused != bFocused
        {
            bGameProcessFocused := bFocused
            If bFocused
            {
                ; OnGameProcessFocused()
            }
            Else
            {
                ; OnGameProcessFocusLost()
            }
            bUpdateGuiControls := True
        }
    }

    If bUpdateGuiControls
    {
        UpdateGuiControls()
    }
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
