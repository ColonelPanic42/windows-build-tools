;!/usr/bin/makensis

; This NSIS script creates an installer for GNU ARM Eclipse Build Tools.

; Copyright (C) 2006-2012 Stefan Weil
; Copyright (c) 2014 Liviu Ionescu
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) version 3 or any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; NSIS_WIN32_MAKENSIS

!define PRODNAME "Build Tools"
!define PRODLCNAME "build-tools"
!define PRODUCT "GNU ARM Eclipse\${PRODNAME}"
!define URL     "http://gnuarmeclipse.livius.net"

!define UNINST_EXE "$INSTDIR\${PRODLCNAME}-uninstall.exe"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"

!define INSTALL_LOCATION_KEY "InstallFolder"

; Use maximum compression.
SetCompressor /SOLID lzma

!include "MUI2.nsh"

; The name of the installer.
Name "GNU ARM Eclipse ${PRODNAME}"

; The file to write
OutFile "${OUTFILE}"

; The default installation directory.
!ifdef W64
InstallDir "$PROGRAMFILES64\GNU ARM Eclipse\${PRODNAME}"
!else
InstallDir "$PROGRAMFILES\GNU ARM Eclipse\${PRODNAME}"
!endif

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
!ifdef W64
InstallDirRegKey HKLM "Software\${PRODLCNAME}64-gnuarmeclipse" "${INSTALL_LOCATION_KEY}"
!else
InstallDirRegKey HKLM "Software\${PRODLCNAME}32-gnuarmeclipse" "${INSTALL_LOCATION_KEY}"
!endif

; Request administrator privileges for Windows Vista and up.
RequestExecutionLevel admin

;--------------------------------
; Interface Settings.
!define MUI_ICON "${NSIS_FOLDER}\${PRODLCNAME}-nsis.ico"
!define MUI_UNICON "${NSIS_FOLDER}\${PRODLCNAME}-nsis.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSIS_FOLDER}\${PRODLCNAME}-nsis.bmp"

;--------------------------------
; Pages.

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${INSTALL_FOLDER}\COPYING"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_LINK "Visit the GNU ARM Eclipse site!"
!define MUI_FINISHPAGE_LINK_LOCATION "${URL}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Languages.

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"

;--------------------------------

; The stuff to install.
Section "${PRODNAME} (required)"

SectionIn RO

; Set output path to the installation directory.
SetOutPath "$INSTDIR\usr\bin"
File /r "${INSTALL_FOLDER}\usr\bin\*.exe"

SetOutPath "$INSTDIR\license"
File /r "${INSTALL_FOLDER}\license\*"

SetOutPath "$INSTDIR"
File "${INSTALL_FOLDER}\INFO.txt"

SetOutPath "$INSTDIR\gnuarmeclipse"
File /r "${INSTALL_FOLDER}\gnuarmeclipse\*"

CreateDirectory "$INSTDIR\tmp"

!ifdef W64
SetRegView 64
!endif

; Write the installation path into the registry
WriteRegStr HKLM "SOFTWARE\${PRODUCT}" "${INSTALL_LOCATION_KEY}" "$INSTDIR"

; Write the uninstall keys for Windows
WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "GNU ARM Eclipse ${PRODNAME}"
WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"${UNINST_EXE}"'
WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
WriteUninstaller "${PRODLCNAME}-uninstall.exe"

SectionEnd


Section "Libraries (DLL)" SectionDll

SetOutPath "$INSTDIR\usr\bin"
File "${INSTALL_FOLDER}\usr\bin\*.dll"

ExecWait '"$INSTDIR\usr\bin\rebase.exe" *.dll'

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts" SectionMenu
CreateDirectory "$SMPROGRAMS\${PRODUCT}"
CreateShortCut "$SMPROGRAMS\${PRODUCT}\Uninstall.lnk" "${UNINST_EXE}" "" "${UNINST_EXE}" 0
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
; Remove registry keys
!ifdef W64
SetRegView 64
!endif
DeleteRegKey HKLM "${UNINST_KEY}"
DeleteRegKey HKLM "SOFTWARE\${PRODUCT}"

; Remove shortcuts, if any
Delete "$SMPROGRAMS\${PRODUCT}\Uninstall.lnk"
RMDir "$SMPROGRAMS\${PRODUCT}"

; Remove uninstaller
Delete "${UNINST_EXE}"

; Remove files and directories used
SetOutPath "$INSTDIR"

RMDir /r "$INSTDIR\*"
RMDir "$INSTDIR\usr\bin"
RMDir "$INSTDIR\usr"

RMDir /r "$INSTDIR"
SectionEnd

;--------------------------------

; Descriptions (mouse-over).
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

!insertmacro MUI_DESCRIPTION_TEXT ${SectionDll}		"Runtime Libraries (DLL)."
!insertmacro MUI_DESCRIPTION_TEXT ${SectionMenu}	"Menu entries."

!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Functions.

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd
