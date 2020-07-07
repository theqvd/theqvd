Notification script for QVD Spy

This should be installed in /usr/lib/qvd/bin/qvdspy-notifier.

It is called from x11vnc, which is called by VMA, using the path in the setting 'vma.x11vnc.confirm.command'


Looks for translation files in /usr/lib/qvd/locale, eg, /usr/lib/qvd/locale/es_ES.UTF-8/LC_MESSAGES/qvdspy-notifier.mo
Looks for pixmaps in the source tree in ext/QVD-Client/pixmaps, windows/installer/pixmaps and /usr/lib/qvd/pixmaps

Uses qvdspy.svg or qvdspy.png as a taskbar icon, or qvd.svg a:wq:::s a fallback.
Uses qvd.svg as a notification picture.


