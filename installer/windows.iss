; Inno Setup script: turns the Windows build into a normal "Setup.exe" installer.
; Run by the GitHub workflow; AppVersion is passed in from pubspec.yaml.

#ifndef AppVersion
  #define AppVersion "1.7.0"
#endif

[Setup]
AppId={{6B1D1C3E-2F1A-4E7B-9C7E-48A1E0C3B5D2}
AppName=Hanzi Steps
AppVersion={#AppVersion}
AppPublisher=Hanzi Steps
DefaultDirName={autopf}\Hanzi Steps
DefaultGroupName=Hanzi Steps
DisableProgramGroupPage=yes
; Install just for the current user, so no administrator password is needed.
PrivilegesRequired=lowest
OutputDir=..
OutputBaseFilename=HanziSteps-Windows-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\hanzi_steps.exe
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Hanzi Steps"; Filename: "{app}\hanzi_steps.exe"
Name: "{autodesktop}\Hanzi Steps"; Filename: "{app}\hanzi_steps.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\hanzi_steps.exe"; Description: "Open Hanzi Steps now"; Flags: nowait postinstall skipifsilent
