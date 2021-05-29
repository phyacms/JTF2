; JTF2: Joint-Trouble-Free for TD2
; A macro application for Tom Clancy's Division® 2 agents

#SingleInstance Force
#NoEnv

; App information
Global AppName := "Joint-Trouble-Free for TD2"
Global AppNameShort := "JTF2"
Global AppIconPath := "JTF2.ico"
Global Version := "0.0.1"
Global RepositoryLink = "https://github.com/phyacms/JTF2"
Global GameProcessName = "TheDivision2.exe"
Global LaunchCommand = "uplay://launch/4932/0"

; Entry
AppMain()
Return

;===============================================================

; Main function
AppMain()
{
    SetWorkingDir %A_ScriptDir%
    SetBatchLines -1

    Menu, Tray, Icon, %AppIconPath%, 1, 1

	WindowWidth := 540
	WindowHeight := 272

    VersionTxt := " v" + Version
    Gui Add, StatusBar,, %VersionTxt%

    Gui Show, w%WindowWidth% h%WindowHeight%, %AppName%

    Return
}

GuiClose:
ExitApp
