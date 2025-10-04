; tool/package_windows.iss

[Setup]
AppId=com.masum.catatan_kaki
AppName=Catatan Kaki
AppVersion={#AppVersion}
AppPublisher=Catatan Kaki Team
DefaultDirName={autopf}\Catatan Kaki
DefaultGroupName=Catatan Kaki
OutputBaseFilename=catatan-kaki-setup
OutputDir=dist
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\catatan_kaki.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Catatan Kaki"; Filename: "{app}\catatan_kaki.exe"
Name: "{autodesktop}\Catatan Kaki"; Filename: "{app}\catatan_kaki.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\catatan_kaki.exe"; Description: "{cm:LaunchProgram,Catatan Kaki}"; Flags: nowait postinstall skipifsilent
