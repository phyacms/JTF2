; JTF2: Joint-Trouble-Free for TD2
; A macro application for Tom Clancy's Division® 2 agents

#SingleInstance Force
#NoEnv

; App information
Global AppName := "JTF2: Joint-Trouble-Free for TD2"
Global AppNameShort := "JTF2"
Global AppIconPath := "JTF2.ico"
Global AppConfigPath = "JTF2.ini"
Global Version := "1.0.0"
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
Global OpenInvCacheMacroName := "OpenInvCacheMacro"
Global OpenApparelCacheMacroName := "OpenApparelCacheMacro"

; Global variables
Global bGameProcessDetectedOnce := False
Global bGameProcessDetected := False
Global bGameProcessFocused := False
Global bEditing := False
Global AutoClickInterval := IntervalMinimum
Global CurrentAutoClickMode
Global bAutoClicking := False
Global bRunningOpenInvCacheMacro := False
Global bRunningOpenApparelCacheMacro := False
Global bMacroPressedF := False
Global bMacroPressedX := False
Global bMacroPressedQ := False
Global bMacroPressedE := False
Global bCancelSummitMatchmaking := False

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
	SetTimer, Timer_DetectGameProcess, Delete
    FinishAutoClick()
    AbortRunningMacro()
    SaveSettings()
    ExitApp
}

;===============================================================

; Gui controls

Global HKToggleActivation
Global HKToggleAutoClick
Global HKRotateAutoClickMode
Global HKAlterClickKey
Global HKRunOpenInvCacheMacro
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
Global CBRunOpenInvCacheMacro
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
If (!IsEditing())
{
    GuiControlGet, bChk,, CBActivate
    If bChk
        GuiControl,, CBActivate, 0
    Else
        GuiControl,, CBActivate, 1
    ApplySettings()
}
Return

HKToggleAutoClick:
If (!IsEditing())
{
    GuiControlGet, bChk,, CBToggleAutoClick
    If bChk
        GuiControl,, CBToggleAutoClick, 0
    Else
        GuiControl,, CBToggleAutoClick, 1
    ApplySettings()
}
Return

HKRotateAutoClickMode:
If (!IsEditing())
{
    GuiControlGet, bPressMode,, RadioAutoClickPressMode
    GuiControlGet, bRepeatMode,, RadioAutoClickRepeatMode
    If bPressMode
        GuiControl,, RadioAutoClickRepeatMode, 1
    Else If bRepeatMode
        GuiControl,, RadioAutoClickPressMode, 1
    ApplySettings()
}
Return

HKAlterClickKey:
If (!IsEditing())
{
    If (IsAlternativeClickKeyAllowed())
        OnClick()
}
Return

HKRunOpenInvCacheMacro:
If !IsEditing()
{
    If !IsMacroRunning()
    {
        RunOpenInvCacheMacro()
    }
    Else If IsOpenInvCacheMacroRunning()
    {
        AbortOpenInvCacheMacro()
    }
}
Return

HKRunOpenApparelCacheMacro:
If !IsEditing()
{
    If !IsMacroRunning()
    {
        RunOpenApparelCacheMacro()
    }
    Else If IsOpenApparelCacheMacroRunning()
    {
        AbortOpenApparelCacheMacro()
    }
}
Return

HKRunSummitEvMacro:
If !IsEditing()
{
    RunSummitEvMacro(bCancelSummitMatchmaking)
    bCancelSummitMatchmaking := !bCancelSummitMatchmaking
}
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
    Gui Add, CheckBox, x352 y52 w84 h20 vCBRunOpenInvCacheMacro gEventUserChangedGuiControl, Inventory
    Gui Add, Hotkey, x440 y52 w24 w84 vHKRunOpenInvCacheMacro
    Gui Add, CheckBox, x352 y74 w84 h20 vCBRunOpenApparelCacheMacro gEventUserChangedGuiControl, Apparel
    Gui Add, Hotkey, x440 y74 w24 w84 vHKRunOpenApparelCacheMacro

    Gui Add, GroupBox, x336 y112 w200 h54, Summit
    Gui Add, CheckBox, x352 y132 w84 h20 vCBRunSummitEvMacro gEventUserChangedGuiControl, Matchmaking
    Gui Add, Hotkey, x440 y132 w24 w84 vHKRunSummitEvMacro

    Gui Add, CheckBox, x338 y192 w120 h20 vCBCloseOnGameExit, Close on game exit
    Gui Add, Button, x336 y212 w64 h32 vBtnEdit gEventBtnEdit, {Edit}
    Gui Add, Button, x400 y212 w52 h32 gEventBtnSetToDefault, Set to Default
    Gui Add, Button, x472 y212 w64 h32 gEventBtnClose, Close

    VersionTxt := " v" + Version
    Gui Add, StatusBar, vSBStatus, %VersionTxt%

    SetupGuiControls(!FileExist(AppConfigPath))
    ApplySettings()

    GuiControl, Focus, BtnHelp
    Gui Show, w%WindowWidth% h%Window24%, %AppName%

    Return
}

SetupGuiControls(bUseDefault)
{
    If !bUseDefault
    {
        LoadSettings()
    }
    Else
    {
		GuiControl,, HKToggleActivation, ``
		GuiControl,, HKToggleAutoClick, XButton1
		GuiControl,, HKRotateAutoClickMode, !C
		GuiControl,, HKAlterClickKey, C
		GuiControl,, HKRunOpenInvCacheMacro, F9
		GuiControl,, HKRunOpenApparelCacheMacro, F10
		GuiControl,, HKRunSummitEvMacro, F11

		GuiControl,, EBInterval, %IntervalMinimum%
		GuiControl,, RadioAutoClickPressMode, 1
		GuiControl,, CBToggleAutoClick, 0
		GuiControl,, CBToggleAutoClickModeByHotkey, 0
		GuiControl,, CBUseAlterClickKey, 0
		GuiControl,, CBRunOpenInvCacheMacro, 1
		GuiControl,, CBRunOpenApparelCacheMacro, 1
		GuiControl,, CBRunSummitEvMacro, 0
		GuiControl,, CBCloseOnGameExit, 1
    }
}

UpdateGuiControls()
{
    GuiControl,, EBInterval, %AutoClickInterval%

    If IsEditing()
    {
        GuiControl,, BtnEdit, Done

        GuiControl, Enabled, HKToggleActivation
        GuiControl, Enabled, HKToggleAutoClick
        GuiControl, Enabled, HKRotateAutoClickMode
        GuiControl, Enabled, HKAlterClickKey
        GuiControl, Enabled, HKRunOpenInvCacheMacro
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
        GuiControl, Disabled, HKRunOpenInvCacheMacro
        GuiControl, Disabled, HKRunOpenApparelCacheMacro
        GuiControl, Disabled, HKRunSummitEvMacro
        GuiControl, Disabled, EBInterval
    }
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
    AbortRunningMacro()

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

SaveSettings()
{
    FileDelete, %AppConfigPath%
    Gui, Submit, NoHide

    If IsCloseOnGameExitEnabled()
        IniWrite, 1, %AppConfigPath%, Preferences, CloseOnGameExit

    IniWrite, %AutoClickInterval%, %AppConfigPath%, Configs, ClickInterval
    IniWrite, %CurrentAutoClickMode%, %AppConfigPath%, Configs, AutoClickMode

    If IsAutoClickModeToggleEnabled()
        IniWrite, 1, %AppConfigPath%, Configs, ToggleAutoClickModeByHotkey
    If IsAlternativeClickKeyAllowed()
        IniWrite, 1, %AppConfigPath%, Configs, UseAlternativeClickKey

    If IsOpenInvCacheMacroEnabled()
        IniWrite, 1, %AppConfigPath%, Configs, EnableOpenInventoryCache
    If IsOpenApparelCacheMacroEnabled()
        IniWrite, 1, %AppConfigPath%, Configs, EnableOpenApparelCache
    If IsRunSummitElevatorMacroEnabled()
        IniWrite, 1, %AppConfigPath%, Configs, EnableSummitEvMacro

    IniWrite, %HKToggleActivation%, %AppConfigPath%, Hotkeys, ToggleActivation
    IniWrite, %HKToggleAutoClick%, %AppConfigPath%, Hotkeys, ToggleAutoClickBy
    IniWrite, %HKRotateAutoClickMode%, %AppConfigPath%, Hotkeys, ToggleModeBy
    IniWrite, %HKAlterClickKey%, %AppConfigPath%, Hotkeys, AlternativeClickKey
    IniWrite, %HKRunOpenInvCacheMacro%, %AppConfigPath%, Hotkeys, RunOpenInventoryCacheMacro
    IniWrite, %HKRunOpenApparelCacheMacro%, %AppConfigPath%, Hotkeys, RunOpenApparelCacheMacro
    IniWrite, %HKRunSummitEvMacro%, %AppConfigPath%, Hotkeys, RunSummitElevatorMacro
}

LoadSettings()
{
    IniRead, bChk, %AppConfigPath%, Preferences, CloseOnGameExit, False
    GuiControl,, CBCloseOnGameExit, % bChk = True

    IniRead, Interval, %AppConfigPath%, Configs, ClickInterval, %IntervalMinimum%
	GuiControl,, EBInterval, %Interval%
    IniRead, AutoClickModeName, %AppConfigPath%, Configs, AutoClickMode, AutoClickModeNamePress
	GuiControl,, RadioAutoClickPressMode, 1
    If AutoClickModeName = %AutoClickModeNameRepeat%
		GuiControl,, RadioAutoClickRepeatMode, 1

    IniRead, bChk, %AppConfigPath%, Configs, ToggleAutoClickModeByHotkey, False
    GuiControl,, CBToggleAutoClickModeByHotkey, % bChk = True
    IniRead, bChk, %AppConfigPath%, Configs, UseAlternativeClickKey, False
    GuiControl,, CBUseAlterClickKey, % bChk = True

    IniRead, bChk, %AppConfigPath%, Configs, EnableOpenInventoryCache, True
    GuiControl,, CBRunOpenInvCacheMacro, % bChk = True
    IniRead, bChk, %AppConfigPath%, Configs, EnableOpenApparelCache, True
    GuiControl,, CBRunOpenApparelCacheMacro, % bChk = True
    IniRead, bChk, %AppConfigPath%, Configs, EnableSummitEvMacro, False
    GuiControl,, CBRunSummitEvMacro, % bChk = True

    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, ToggleActivation, ``
    GuiControl,, HKToggleActivation, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, ToggleAutoClickBy, XButton1
    GuiControl,, HKToggleAutoClick, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, ToggleModeBy, !C
    GuiControl,, HKRotateAutoClickMode, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, AlternativeClickKey, C
    GuiControl,, HKAlterClickKey, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, RunOpenInventoryCacheMacro, F9
    GuiControl,, HKRunOpenInvCacheMacro, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, RunOpenApparelCacheMacro, F10
    GuiControl,, HKRunOpenApparelCacheMacro, %LoadedHotkey%
    IniRead, LoadedHotkey, %AppConfigPath%, Hotkeys, RunSummitElevatorMacro, F11
    GuiControl,, HKRunSummitEvMacro, %LoadedHotkey%
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
                AbortRunningMacro()
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

    If IsGameProcessDetectedOnce() && IsCloseOnGameExitEnabled()
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

IsCloseOnGameExitEnabled()
{
    GuiControlGet, bEnabled,, CBCloseOnGameExit
    return bEnabled
}

;===============================================================

IsAutoClickModeToggleEnabled()
{
    GuiControlGet, bEnabled,, CBToggleAutoClickModeByHotkey
    Return bEnabled
}

IsAlternativeClickKeyAllowed()
{
    GuiControlGet, bAllowed,, CBUseAlterClickKey
    Return bAllowed
}

;===============================================================

IsOpenInvCacheMacroEnabled()
{
    GuiControlGet, bEnabled,, CBRunOpenInvCacheMacro
    Return bEnabled
}

IsOpenApparelCacheMacroEnabled()
{
    GuiControlGet, bEnabled,, CBRunOpenApparelCacheMacro
    Return bEnabled
}

IsRunSummitElevatorMacroEnabled()
{
    GuiControlGet, bEnabled,, CBRunSummitEvMacro
    Return bEnabled
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
            Hotkey, %HKToggleActivation%, HKToggleActivation, On

        If IsActivated()
        {
            If Not !HKToggleAutoClick
                Hotkey, %HKToggleAutoClick%, HKToggleAutoClick, On

            GuiControlGet, bChk,, CBToggleAutoClickModeByHotkey
            If bChk && Not !HKRotateAutoClickMode
                Hotkey, %HKRotateAutoClickMode%, HKRotateAutoClickMode, On
            GuiControlGet, bChk,, CBUseAlterClickKey
            If bChk && Not !HKAlterClickKey
                Hotkey, %HKAlterClickKey%, HKAlterClickKey, On

            GuiControlGet, bChk,, CBRunOpenInvCacheMacro
            If bChk && Not !HKRunOpenInvCacheMacro
                Hotkey, %HKRunOpenInvCacheMacro%, HKRunOpenInvCacheMacro, On
            GuiControlGet, bChk,, CBRunOpenApparelCacheMacro
            If bChk && Not !HKRunOpenApparelCacheMacro
                Hotkey, %HKRunOpenApparelCacheMacro%, HKRunOpenApparelCacheMacro, On

            GuiControlGet, bChk,, CBRunSummitEvMacro
            If bChk && Not !HKRunSummitEvMacro
                Hotkey, %HKRunSummitEvMacro%, HKRunSummitEvMacro, On
        }
    }
}

UnbindAllHotkeyBindings()
{
    If Not !HKToggleActivation
        Hotkey, %HKToggleActivation%, HKToggleActivation, Off
    If Not !HKToggleAutoClick
        Hotkey, %HKToggleAutoClick%, HKToggleAutoClick, Off
    If Not !HKRotateAutoClickMode
        Hotkey, %HKRotateAutoClickMode%, HKRotateAutoClickMode, Off
    If Not !HKAlterClickKey
        Hotkey, %HKAlterClickKey%, HKAlterClickKey, Off
    If Not !HKRunOpenInvCacheMacro
        Hotkey, %HKRunOpenInvCacheMacro%, HKRunOpenInvCacheMacro, Off
    If Not !HKRunOpenApparelCacheMacro
        Hotkey, %HKRunOpenApparelCacheMacro%, HKRunOpenApparelCacheMacro, Off
    If Not !HKRunSummitEvMacro
        Hotkey, %HKRunSummitEvMacro%, HKRunSummitEvMacro, Off
}

;===============================================================

ClampInterval(Interval)
{
    If Interval < %IntervalMinimum%
        Interval := IntervalMinimum
    If Interval > %IntervalMaximum%
        Interval := IntervalMaximum
    Return Interval
}

SetAutoClickInterval(Interval)
{
    Interval := ClampInterval(Interval)
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
    SetTimer, Timer_AutoClick, Delete
}

OnClick()
{
    If IsGameProcessFocused() && !IsEditing() && IsActivated() && IsAutoClickEnabled()
    {
        bStart
            := CurrentAutoClickMode = AutoClickModeNamePress
            || (CurrentAutoClickMode = AutoClickModeNameRepeat && !IsAutoClicking)
        If (bStart)
        {
            StartAutoClick()
            Return
        }
    }
    FinishAutoClick()
}

RunClick()
{
    If IsGameProcessFocused() && IsActivated() && IsAutoClickEnabled()
    {
        bKeyDown
            := GetKeyState("LButton", "P")
            || (IsAlternativeClickKeyAllowed() && GetKeyState(HKAlterClickKey, "P"))
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

;===============================================================

IsMacroRunning()
{
    Return IsOpenInvCacheMacroRunning()
        || IsOpenApparelCacheMacroRunning()
}

AbortRunningMacro()
{
    AbortOpenInvCacheMacro()
    AbortOpenApparelCacheMacro()
}

;===============================================================

IsOpenInvCacheMacroRunning()
{
    Return bRunningOpenInvCacheMacro
}

RunOpenInvCacheMacro()
{
    bRunningOpenInvCacheMacro := True
    SetTimer, MacroStep_OpenInvCache_0, 25
}

AbortOpenInvCacheMacro()
{
    SetTimer, MacroStep_OpenInvCache_0, Delete
    SetTimer, MacroStep_OpenInvCache_1, Delete
    SetTimer, MacroStep_OpenInvCache_2, Delete
    SetTimer, MacroStep_OpenInvCache_3, Delete
    SetTimer, MacroStep_OpenInvCache_4, Delete
    SetTimer, MacroStep_OpenInvCache_5, Delete
    bRunningOpenInvCacheMacro := False

    If bMacroPressedF
    {
        Send, {F Up}
        bMacroPressedF := False
    }
    If bMacroPressedQ
    {
        Send, {Q Up}
        bMacroPressedQ := False
    }
    If bMacroPressedE
    {
        Send, {E Up}
        bMacroPressedE := False
    }
}

MacroStep_OpenInvCache_0:
SetTimer, MacroStep_OpenInvCache_0, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {Click}
    SetTimer, MacroStep_OpenInvCache_1, 200
}
Return

MacroStep_OpenInvCache_1:
SetTimer, MacroStep_OpenInvCache_1, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {F Down}
    bMacroPressedF := True
    SetTimer, MacroStep_OpenInvCache_2, 1100
}
Return

MacroStep_OpenInvCache_2:
SetTimer, MacroStep_OpenInvCache_2, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {Q Down}
    bMacroPressedQ := True
    SetTimer, MacroStep_OpenInvCache_3, 50
}
Return

MacroStep_OpenInvCache_3:
SetTimer, MacroStep_OpenInvCache_3, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {Q Up}
    bMacroPressedQ := False
    SetTimer, MacroStep_OpenInvCache_4, 200
}
Return

MacroStep_OpenInvCache_4:
SetTimer, MacroStep_OpenInvCache_4, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {E Down}
    bMacroPressedE := True
    SetTimer, MacroStep_OpenInvCache_5, 80
}
Return

MacroStep_OpenInvCache_5:
SetTimer, MacroStep_OpenInvCache_5, Delete
If IsOpenInvCacheMacroRunning()
{
    Send, {F Up}
    bMacroPressedF := False
    Send, {E Up}
    bMacroPressedE := False
    SetTimer, MacroStep_OpenInvCache_0, 600
}
Return

;===============================================================

IsOpenApparelCacheMacroRunning()
{
    Return bRunningOpenApparelCacheMacro
}

RunOpenApparelCacheMacro()
{
    bRunningOpenApparelCacheMacro := True
    SetTimer, MacroStep_OpenApparelCache_0, 25
}

AbortOpenApparelCacheMacro()
{
    SetTimer, MacroStep_OpenApparelCache_0, Delete
    SetTimer, MacroStep_OpenApparelCache_1, Delete
    SetTimer, MacroStep_OpenApparelCache_2, Delete
    SetTimer, MacroStep_OpenApparelCache_3, Delete
    SetTimer, MacroStep_OpenApparelCache_4, Delete
    SetTimer, MacroStep_OpenApparelCache_5, Delete
    SetTimer, MacroStep_OpenApparelCache_6, Delete
    SetTimer, MacroStep_OpenApparelCache_7, Delete
    bRunningOpenApparelCacheMacro := False

    If bMacroPressedX
    {
        Send, {X Up}
        bMacroPressedX := False
    }
    If bMacroPressedQ
    {
        Send, {Q Up}
        bMacroPressedQ := False
    }
    If bMacroPressedE
    {
        Send, {E Up}
        bMacroPressedE := False
    }
}

MacroStep_OpenApparelCache_0:
SetTimer, MacroStep_OpenApparelCache_0, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {Down Down}
    SetTimer, MacroStep_OpenApparelCache_1, 150
}
Return

MacroStep_OpenApparelCache_1:
SetTimer, MacroStep_OpenApparelCache_1, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {Down Up}
    SetTimer, MacroStep_OpenApparelCache_2, 150
}
Return

MacroStep_OpenApparelCache_2:
SetTimer, MacroStep_OpenApparelCache_2, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {X Down}
    bMacroPressedX := True
    SetTimer, MacroStep_OpenApparelCache_3, 3500
}
Return

MacroStep_OpenApparelCache_3:
SetTimer, MacroStep_OpenApparelCache_3, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {X Up}
    bMacroPressedX := False
    SetTimer, MacroStep_OpenApparelCache_4, 750
}
Return

MacroStep_OpenApparelCache_4:
SetTimer, MacroStep_OpenApparelCache_4, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {Q Down}
    bMacroPressedQ := True
    SetTimer, MacroStep_OpenApparelCache_5, 150
}
Return

MacroStep_OpenApparelCache_5:
SetTimer, MacroStep_OpenApparelCache_5, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {Q Up}
    bMacroPressedQ := False
    SetTimer, MacroStep_OpenApparelCache_6, 150
}
Return

MacroStep_OpenApparelCache_6:
SetTimer, MacroStep_OpenApparelCache_6, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {E Down}
    bMacroPressedE := True
    SetTimer, MacroStep_OpenApparelCache_7, 150
}
Return

MacroStep_OpenApparelCache_7:
SetTimer, MacroStep_OpenApparelCache_7, Delete
If IsOpenApparelCacheMacroRunning()
{
    Send, {E Up}
    bMacroPressedE := False
    SetTimer, MacroStep_OpenApparelCache_0, 1000
}
Return

;===============================================================

RunSummitEvMacro(bCancel)
{
	Send, {M Down}
	Sleep, 54
	Send, {M Up}
	Sleep, 1500
	Send, {E Down}
	Sleep, 68
	Send, {E UP}
	Sleep, 50
	Send, {E Down}
	Sleep, 50
	Send, {E Up}
	Sleep, 50
	Send, {S Down}
	Sleep, 50
	Send, {S up}
	Sleep, 50
	Send, {S Down}
	Sleep, 50
	Send, {S Up}
	Sleep, 50
	Send, {D Down}
	Sleep, 50
	Send, {D Up}
	Sleep, 50
	Send, {D Down}
	Sleep, 50
	Send, {D up}
	Sleep, 50
	Send, {Space Down}
	Sleep, 50
	Send, {Space Up}
	Sleep, 50
    If !bCancel
    {
        Send, {S Down}
        Sleep, 50
        Send, {S Up}
        Sleep, 50
        Send, {S Down}
        Sleep, 50
        Send, {S up}
        Sleep, 50
        Send, {S Down}
        Sleep, 50
        Send, {S Up}
        Sleep, 50
        Send, {S Down}
        Sleep, 50
        Send, {S Up}
        Sleep, 50
        Send, {Space Down}
        Sleep, 50
        Send, {Space up}
        Sleep, 50
    }
    Else
    {
	    Send, {M Down}
	    Sleep, 50
	    Send, {M Up}
    	Sleep, 50
    }
}
