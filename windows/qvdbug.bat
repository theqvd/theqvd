@echo off

set docsdir=

FOR /F "skip=2 tokens=3 delims=	" %%G IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') DO (SET docsdir=%%G)

IF "%docsdir%"=="" (
  echo It doesn't look like we were running in Windows XP, good!
  FOR /F "skip=2 tokens=3" %%G IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') DO (SET docsdir=%%G)
)

set out=%docsdir%\qvdbug.txt

echo This program collects information about your system and the QVD client logs and saves it into "%out%"
echo The report may contain sensitive information as the network configuration of your system or your QVD usage history. Feel free to review it and remove anything you don't want to share.
echo In any case, Qindel commits to keep the provided information private and to use it for troubleshooting and debugging purposes exclusively.

echo *
echo Working...

echo "QVD bug report" >"%out%"

echo * Saving Windows version
echo ------------------------------ >>"%out%"
echo VER -------------------------- >>"%out%"
ver                                 >>"%out%"

echo * Saving environment
echo ------------------------------ >>"%out%"
echo SET -------------------------- >>"%out%"
set                                 >>"%out%"

echo * Saving network configuration
echo ------------------------------ >>"%out%"
echo ipconfig --------------------- >>"%out%"
ipconfig /all                       >>"%out%"

echo * Checking connectivity with QVD demo server
echo ------------------------------ >>"%out%"
echo ping ------------------------- >>"%out%"
ping demo.theqvd.com                >>"%out%"

echo * Saving client configuration
echo ------------------------------ >>"%out%"
echo client.conf ------------------ >>"%out%"
type "%APPDATA%\QVD\client.conf"    >>"%out%"

echo * Saving QVD client logs
echo ------------------------------ >>"%out%"
echo qvd-client.log --------------- >>"%out%"
type "%APPDATA%\QVD\qvd-client.log" >>"%out%"

echo * Saving NX proxy logs
echo ------------------------------ >>"%out%"
echo nxproxy.log ------------------ >>"%out%"
type "%APPDATA%\QVD\nxproxy.log"    >>"%out%"

echo * Saving X server logs
echo ------------------------------ >>"%out%"
echo xserver.log ------------------ >>"%out%"
type "%APPDATA%\QVD\xserver.log"    >>"%out%"

echo * Saving QVD client data directory listing
echo ------------------------------ >>"%out%"
echo dir -------------------------- >>"%out%"
dir /S "%APPDATA%\QVD"              >>"%out%"

echo Done!
echo You may like to attach the generated file at "%out%" to an email and sent it to bugs@theqvd.com
pause 30