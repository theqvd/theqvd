@echo off

set QVDPATH=.

wperl ^
-I ..\..\ext\IO-Socket-Forwarder\lib ^
-I ..\..\ext\QVD-Config-Core\lib ^
-I ..\..\ext\QVD-Config\lib ^
-I ..\..\ext\QVD-Client\lib ^
-I ..\..\ext\QVD-HTTP\lib\ ^
-I ..\..\ext\QVD-HTTPC\lib ^
-I ..\..\ext\QVD-Log\lib ^
-I ..\..\ext\QVD-URI\lib ^
..\..\ext\QVD-Client\bin\qvd-gui-client.pl
