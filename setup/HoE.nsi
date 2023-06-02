Unicode True
RequestExecutionLevel admin
SetCompressor /SOLID zlib
AutoCloseWindow true
Icon main.ico
XPStyle on

!include StrData.nsi

!include "FileFunc.nsh"
!insertmacro GetTime

!define TEMP1 $R0 

ReserveFile /plugin InstallOptions.dll
ReserveFile "runapp.ini"

OutFile "HeroesOfEquestria-1.0.0-Win32.exe"

var is_update

Page directory
Page components
Page instfiles
Page custom SetRunApp ValidateRunApp "$(AfterParams)" 

UninstPage uninstConfirm
UninstPage instfiles

Name $(GameGameName)

Function .onInit
  InitPluginsDir
  File /oname=$PLUGINSDIR\runapp.ini "runapp.ini"

  StrCpy $INSTDIR $PROGRAMFILES\HoE

  IfFileExists $INSTDIR\bin\HoE.exe +3
  StrCpy $is_update "0"
  Goto +2
  StrCpy $is_update "1"
  
FunctionEnd

Function .onInstSuccess
  StrCmp $is_update "1" SkipAll

  ReadINIStr ${TEMP1} "$PLUGINSDIR\runapp.ini" "Field 1" "State"
  StrCmp ${TEMP1} "0" SkipDesktop

  SetOutPath $INSTDIR\bin
  CreateShortCut "$DESKTOP\$(GameName).lnk" "$INSTDIR\bin\HoE.exe" "" 

SkipDesktop:

  ReadINIStr ${TEMP1} "$PLUGINSDIR\runapp.ini" "Field 2" "State"
  StrCmp ${TEMP1} "0" SkipRun

  Exec $INSTDIR\bin\HoE.exe

  SkipRun:
  SkipAll:

FunctionEnd

Function un.onUninstSuccess
  MessageBox MB_OK "$(MsgUninstOK)"
FunctionEnd

Function un.onUninstFailed
  MessageBox MB_OK "$(MsgUninstError)"
FunctionEnd

Function .onInstFailed
  MessageBox MB_OK "$(MsgInstError)"
FunctionEnd

Section "$(GameGameName)"
  SectionIn RO

  StrCmp $is_update "0" SkipSleep
  Sleep 3000
  SkipSleep:

  SetOutPath $INSTDIR
  File main.ico

  SetOutPath $INSTDIR\bin
  File ..\bin\HoE.exe
  File ..\bin\D3DX81ab.dll

  SetOutPath $INSTDIR\configs
  File /r ..\configs\*
  SetOutPath $INSTDIR\fonts
  File /r ..\fonts\*
  SetOutPath $INSTDIR\images
  File /r ..\images\*
  SetOutPath $INSTDIR\maps
  File /r ..\maps\*
  SetOutPath $INSTDIR\scenes
  File /r ..\scenes\*
  SetOutPath $INSTDIR\usermaps
  File /r ..\usermaps\*

  StrCmp $is_update "1" Skip2
  
  WriteUninstaller $INSTDIR\Uninst.exe

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "DisplayName" "$(GameGameName)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "UninstallString" "$\"$INSTDIR\Uninst.exe$\""
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "EstimatedSize" 0x00006480
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "DisplayIcon" $INSTDIR\main.ico

  ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "InstallDate"  "$2$1$0"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "Publisher"  "$(DeveloperName)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE" \
                 "DisplayVersion"  "1.0.0"

  SetOutPath $INSTDIR\bin
  CreateDirectory "$SMPROGRAMS\$(GameName)"
  CreateShortCut "$SMPROGRAMS\$(GameName)\$(GameName).lnk" "$INSTDIR\bin\HoE.exe" "" 

Skip2:

SectionEnd

Section "$(SectionDocs)"
  SetOutPath $INSTDIR\manuals
  File /r ..\manuals\*
SectionEnd

Section "Uninstall"
  RMDir /r $INSTDIR
  RMDir /r "$SMPROGRAMS\$(GameName)"
  Delete "$DESKTOP\$(GameName).lnk"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HoE"
SectionEnd

Function SetRunApp

  Push ${TEMP1}

  InstallOptions::dialog "$PLUGINSDIR\runapp.ini"
    Pop ${TEMP1}
  
  Pop ${TEMP1}

FunctionEnd

Function ValidateRunApp

FunctionEnd
