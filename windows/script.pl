#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use Getopt::Long;

my $suffix = "";
my ($revision) = `svn info .` =~ /^Revision:\s*(\d+)/m;

GetOptions("suffix|s=s" => \$suffix) or die "Getopt failed";

my %pl = ( me       => $0,
		   version  => '3.5.0',
		   revision => $revision,
           suffix   => $suffix );

while (<DATA>) {
	s|{pl:(\w+)}|$pl{$1} // warn "unknown variable {pl:$1}"|ge;
	print;
}

__DATA__
[You]
; This file is automatically generated by {pl:me}
; Any changes performed here will be lost!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{DD625C30-A6B1-4C48-A3C2-19B39771028F}
AppName=QVD Client
AppVerName=QVD Client {pl:version}-{pl:revision}{pl:suffix}
AppVersion={pl:version}-{pl:revision}
AppPublisher=QindelGroup
AppPublisherURL=http://theqvd.com/
AppSupportURL=http://theqvd.com/
AppUpdatesURL=http://theqvd.com/
DefaultDirName={pf}\QVD
DisableDirPage=yes
DefaultGroupName=QVD Client
DisableProgramGroupPage=yes
OutputBaseFilename=qvd-client-setup-{pl:version}-{pl:revision}{pl:suffix}
Compression=lzma
SolidCompression=yes
SetupIconFile=installer\pixmaps\qvd.ico
AlwaysRestart=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "installer\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\NX\*"; DestDir: "{app}\NX"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\pulseaudio\*"; DestDir: "{app}\pulseaudio"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "installer\system32\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "installer\Xming\*"; DestDir: "{app}\Xming"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\VcxSrv\*"; DestDir: "{app}\VcxSrv"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\pixmaps\*"; DestDir: "{app}\pixmaps"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\locale\*"; DestDir: "{app}\locale"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "installer\qvd-client.exe"; DestDir: "{app}\bin"; Flags: ignoreversion
; Source: "c:\Strawberry\perl\bin\libstdc++-6.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\QVD Client"; Filename: "{app}\bin\qvd-client.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\QVD Client"; Filename: "{app}\bin\qvd-client.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Registry]
; Make LanmanServer accept 127.0.0.1 as its netbios name 
; REQUIRED for printing to work on Windows 7 
Root: HKLM; Subkey: "System\CurrentControlSet\Control\Lsa\MSV1_0"; ValueType: multisz; ValueName: "BackConnectionHostNames"; ValueData: "127.0.0.1{break}localhost"; 
Root: HKLM; Subkey: "System\CurrentControlSet\Services\LanmanServer\Parameters"; ValueType: dword; ValueName: "restrictnullsessaccess"; ValueData: "0";
Root: HKLM; Subkey: "System\CurrentControlSet\Control\Lsa"; ValueType: dword; ValueName: "EveryoneIncludesAnonymous"; ValueData: "1";

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
	XmingDir, XmingBackupDir: String;
begin
    Log('In PostInstall script');
	
	XmingDir       := ExpandConstant('{app}') + '\Xming';
	XmingBackupDir := XmingDir + '-backup';
	
	if ( CurStep = ssInstall ) then begin
		Log('In Install stage, looking for Xming directory: ' + XmingDir);
		
		 if DirExists( XmingDir ) then begin
			Log('Trying to rename ' + XmingDir + ' to ' + XmingBackupDir);
			if RenameFile(XmingDir, XmingBackupDir ) then begin
				Log('Rename successful');
			end else begin
				Log('Rename failed!');
			end
		end else begin
			Log('Xming directory not found, ok');
		end
	end
end;

