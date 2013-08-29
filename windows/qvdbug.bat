@echo on

FOR /F "skip=2 tokens=3 delims=	" %%G IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') DO (SET docsdir=%%G)

set out="%docsdir%\qvdbug.txt"

echo "QVD bug report" >"""%out%"""

echo ""                             >>"%out%"
echo "VER ------------------------" >>"%out%"
ver                                 >>"%out%"

echo ""                             >>"%out%"
echo "qvd-client.log -------------" >>"%out%"
type "%APPDATA%\QVD\qvd-client.log" >>"%out%"

echo ""                             >>"%out%"
echo "nxproxy.log ----------------" >>"%out%"
type "%APPDATA%\QVD\nxproxy.log"    >>"%out%"

echo ""                             >>"%out%"
echo "xserver.log ----------------" >>"%out%"
type "%APPDATA%\QVD\xserver.log"    >>"%out%"