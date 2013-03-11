@echo off

perl ^
-d ^
-I ..\..\ext\QVD-Config-Core\lib ^
-I ..\..\ext\QVD-Config\lib ^
-I ..\..\ext\QVD-Client-Slaveclient\lib ^
-I ..\..\ext\QVD-HTTP\lib\ ^
-I ..\..\ext\QVD-HTTPC\lib ^
-I ..\..\ext\QVD-Log\lib ^
-I ..\..\ext\QVD-URI\lib ^
..\..\ext\QVD-Client-SlaveClient\bin\qvd-slaveclient share c:\\
