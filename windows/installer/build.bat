pp -x -gui ^
-I ..\..\ext\IO-Socket-Forwarder\lib ^
-I ..\..\ext\QVD-Config\lib ^
-I ..\..\ext\QVD-Client\lib ^
-I ..\..\ext\QVD-HTTP\lib\ ^
-I ..\..\ext\QVD-HTTPC\lib ^
-I ..\..\ext\QVD-Log\lib ^
-I ..\..\ext\QVD-URI\lib ^
-I c:\strawberry\perl\perl\site\lib ^
-l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxbase28u_gcc_custom.dll ^
-l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_adv_gcc_custom.dll ^
-l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_core_gcc_custom.dll ^
-l C:\strawberry\perl\site\lib\auto\Net\SSLeay\libeay32.dll ^
-l C:\strawberry\perl\site\lib\auto\Net\SSLeay\ssleay32.dll ^
-l C:\strawberry\perl\site\lib\auto\Crypt\OpenSSL\X509\X509.dll ^
--icon QVD-Client\pixmaps\qvd.ico ^
-o qvd-client.exe ^
..\..\ext\QVD-Client\bin\qvd-gui-client.pl

rem -l C:\strawberry\perl\site\lib\auto\Crypt\OpenSSL\X509\libeay32.dll ^

rem -a system32\libeay32_.dll ^
rem -a system32\libssl32_.dll ^
rem -a system32\advapi32.dll ^
rem -a system32\cyggcc_s-1.dll ^
rem -a system32\cygjpeg-7.dll ^
rem -a system32\cygpng12.dll ^
rem -a system32\cygstdc++-6.dll ^
rem -a system32\cygwin1.dll ^
rem -a system32\cygXcomp.dll ^
rem -a system32\cygz.dll ^
rem -a system32\mingwm10.dll ^
rem -a system32\nxproxy.exe ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxbase28u_net_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxbase28u_xml_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_aui_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_gl_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_html_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_media_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_richtext_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_stc_gcc_custom.dll ^
rem -l C:\strawberry\perl\site\lib\Alien\wxWidgets\msw_2_8_10_uni_gcc_3_4\lib\wxmsw28u_xrc_gcc_custom.dll ^
