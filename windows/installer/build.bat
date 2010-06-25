pp -x -gui -I ^
..\..\ext\QVD-HTTPC\lib ^
-I ..\..\ext\QVD-URI\lib ^
-a system32\advapi32.dll ^
-a system32\cyggcc_s-1.dll ^
-a system32\cygjpeg-7.dll ^
-a system32\cygpng12.dll ^
-a system32\cygstdc++-6.dll ^
-a system32\cygwin1.dll ^
-a system32\cygXcomp.dll ^
-a system32\cygz.dll ^
-a system32\libeay32_.dll ^
-a system32\libssl32_.dll ^
-a system32\mingwm10.dll ^
-a system32\nxproxy.exe ^
-I ..\..\ext\QVD-Config\lib ^
-I ..\..\ext\QVD-Log\lib ^
-I ..\..\ext\QVD-Client\lib ^
-I c:\strawberryperl\perl\site\lib ^
-l C:\strawberry\perl\vendor\lib\Alien\wxWidgets\msw_2_9_0_uni_gcc_3_4\lib\wxbase290u_gcc_custom.dll ^
-l C:\strawberry\perl\vendor\lib\Alien\wxWidgets\msw_2_9_0_uni_gcc_3_4\lib\wxmsw290u_core_gcc_custom.dll ^
-l C:\strawberry\perl\vendor\lib\Alien\wxWidgets\msw_2_9_0_uni_gcc_3_4\lib\wxmsw290u_adv_gcc_custom.dll ^
-I ..\..\ext\QVD-HTTP\lib\ ^
-I ..\..\ext\IO-Socket-Forwarder\lib ^
--icon QVD-Client\pixmaps\qvd.ico -o qvd-client.exe ^
..\..\ext\QVD-Client\bin\qvd-gui-client.pl