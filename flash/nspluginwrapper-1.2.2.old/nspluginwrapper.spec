%define name	nspluginwrapper
%define version	1.2.2
%define release	1
#define svndate	DATE

# define 32-bit arch of multiarch platforms
%define arch_32 %{nil}
%ifarch x86_64
%define arch_32 i386
%endif
%ifarch ppc64
%define arch_32 ppc
%endif
%ifarch sparc64
%define arch_32 sparc
%endif

# define target architecture of plugins we want to support
%define target_arch i386

# define target operating system of plugins we want to support
%define target_os linux

# define nspluginswrapper libdir (invariant, including libdir)
%define pkglibdir %{_prefix}/lib/%{name}

# define mozilla plugin dir
%define plugindir %{_libdir}/mozilla/plugins

# define to build a biarch package
# NOTE: biarch builds require a "multilib" capable compiler, which
# should be the default on decent Linux distributions
%define build_biarch		0
%if "%{_arch}:%{arch_32}" == "x86_64:i386"
%define build_biarch		1
%endif
%{expand: %{?_with_biarch:	%%global build_biarch 1}}
%{expand: %{?_without_biarch:	%%global build_biarch 0}}

# define to build a Linux package suitable for other OS (e.g. NetBSD)
# NOTE: this option is *not* needed on Linux usually. However, if you
# need this package to be used verbatim on *BSD systems, you have to
# define this option for your Linux build
%define build_generic		0
%{expand: %{?_with_generic:	%%global build_generic 1}}
%{expand: %{?_without_generic:	%%global build_generic 0}}

# define to build the standalone NPAPI plugins player
%define build_player		1
%{expand: %{?_with_player:	%%global build_player 1}}
%{expand: %{?_without_player:	%%global build_player 0}}

Summary:	A compatibility layer for Netscape 4 plugins
Name:		%{name}
Version:	%{version}
Release:	%{release}
Source0:	%{name}-%{version}%{?svndate:-%{svndate}}.tar.bz2
License:	GPL
Group:		Networking/WWW
Url:		http://gwenole.beauchesne.info/projects/nspluginwrapper/
BuildRequires:	gtk2-devel
Provides:	%{name}-%{_arch} = %{version}-%{release}
Requires:	%{name}-%{target_arch} = %{version}-%{release}
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
nspluginwrapper makes it possible to use Netscape 4 compatible plugins
compiled for %{target_arch} into Mozilla for another architecture, e.g. x86_64.

This package consists in:
  * npviewer: the plugin viewer
  * npwrapper.so: the browser-side plugin
  * nspluginwrapper: a tool to manage plugins installation and update

%if %{build_biarch}
%package %{target_arch}
Summary:	A viewer for %{target_arch} compiled Netscape 4 plugins
Group:		Networking/WWW
%if "%{target_arch}" == "i386"
Requires:	%{_bindir}/linux32
%endif

%description %{target_arch}
nspluginwrapper makes it possible to use Netscape 4 compatible plugins
compiled for %{target_arch} into Mozilla for another architecture, e.g. x86_64.

This package consists in:
  * npviewer: the plugin viewer
  * npwrapper.so: the browser-side plugin
  * nspluginwrapper: a tool to manage plugins installation and update

This package provides the npviewer program for %{target_arch}.
%endif

%if %{build_player}
%package -n nspluginplayer
Summary:	A viewer for %{target_arch} compiled Netscape 4 plugins
Group:		Networking/WWW
BuildRequires:	curl-devel
# XXX: the Gtk version can work with non-wrapped plugins so this ought to be a Suggests: tag
#Requires:	%{name} = %{version}-%{release}

%description -n nspluginplayer
nspluginplayer is a standalone player for NPAPI plugins.
%endif

%prep
%setup -q

%build
%if %{build_biarch}
enable_biarch="--enable-biarch"
%else
enable_biarch="--disable-biarch"
%endif
%if %{build_generic}
enable_generic="--enable-generic"
%else
enable_generic="--disable-generic"
%endif
%if %{build_player}
enable_player="--enable-player"
%else
enable_player="--disable-player"
%endif
mkdir objs
pushd objs
../configure --prefix=%{_prefix} $enable_biarch $enable_generic $enable_player
make
popd

%install
rm -rf $RPM_BUILD_ROOT

make -C objs install DESTDIR=$RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{plugindir}
ln -s %{pkglibdir}/%{_arch}/%{_os}/npwrapper.so $RPM_BUILD_ROOT%{plugindir}/npwrapper.so

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ $1 = 1 ]; then
  %{_bindir}/%{name} -v -a -i
else
  %{_bindir}/%{name} -v -a -u
fi

%preun
if [ $1 = 0 ]; then
  %{_bindir}/%{name} -v -a -r
fi

%files
%defattr(-,root,root)
%doc README COPYING NEWS
%{_bindir}/%{name}
%{plugindir}/npwrapper.so
%dir %{pkglibdir}
%dir %{pkglibdir}/noarch
%{pkglibdir}/noarch/npviewer
%dir %{pkglibdir}/%{_arch}
%dir %{pkglibdir}/%{_arch}/%{_os}
%{pkglibdir}/%{_arch}/%{_os}/npconfig
%if ! %{build_biarch}
%{pkglibdir}/%{_arch}/%{_os}/npviewer
%{pkglibdir}/%{_arch}/%{_os}/npviewer.bin
%{pkglibdir}/%{_arch}/%{_os}/libxpcom.so
%{pkglibdir}/%{_arch}/%{_os}/libnoxshm.so
%endif
%{pkglibdir}/%{_arch}/%{_os}/npwrapper.so

%if %{build_biarch}
%files %{target_arch}
%defattr(-,root,root)
%dir %{pkglibdir}/%{target_arch}
%dir %{pkglibdir}/%{target_arch}/%{target_os}
%{pkglibdir}/%{target_arch}/%{target_os}/npviewer
%{pkglibdir}/%{target_arch}/%{target_os}/npviewer.bin
%{pkglibdir}/%{target_arch}/%{target_os}/libxpcom.so
%{pkglibdir}/%{target_arch}/%{target_os}/libnoxshm.so
%endif

%if %{build_player}
%files -n nspluginplayer
%defattr(-,root,root)
%doc README COPYING NEWS
%{_bindir}/nspluginplayer
%{pkglibdir}/%{_arch}/%{_os}/npplayer
%endif

%changelog
* Fri Jan 02 2009 Gwenole Beauchesne <gb.public@free.fr> 1.2.2-1
- fix support for the VLC plug-in
- fix memory deallocation in NPN_GetStringIdentifiers()
- fix return value if stream creation failed in standalone player

* Fri Dec 26 2008 Gwenole Beauchesne <gb.public@free.fr> 1.2.0-1
- drop obsolete mkruntime scripts
- use valgrind if NPW_USE_VALGRIND=yes
- add support for SunStudio compilers
- add support for Flash Player 10 on OpenSolaris 2008.11
- fix build on non-Linux platforms
- fix NPP_Destroy() to keep NPP instances longer
- fix NPP_Destroy() to destroy the plugin window immediately

* Mon Dec 08 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.10-1
- fix NPPVpluginScriptableNPObject::Invalidate()
- fix condition for delayed NPN_ReleaseObject() call
- fix XEMBED (rework for lost events/focus regressions)
- fix RPC for calls initiated by the plugin (SYNC mode)
- fix invalid RPC after the plugin was NPP_Destroy()'ed

* Mon Dec 01 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.8-1
- delay NPN_ReleaseObject() if there is incoming RPC
- improve plugins restart machinery (Martin Stransky)
- close npviewer.bin sockets on exec()
- close all open files on fork() (initial patch by Dan Walsh)
- make `which` failures silent for soundwrappers (Stanislav Brabec)
- allow direct execution of native plugins if NPW_DIRECT_EXEC is set

* Thu Nov 23 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.6-1
- enable glib memory hooks by default
- lower priority of RPC events so that timeouts are triggered first
- fix string_of_NPVariant() that could make some plugins crash
- fix args release in NPClass::Invoke(|Default)()
- fix memory leak in NPN_GetStringIdentifiers()
- fix NPN_ReleaseObject() that could dereference a deallocated NPObject
- fix (sync) NPObject referenceCount when the object is passed to the plugin
- fix plugin window resize in XEMBED hack mode
- fix "javascript:" streams requests in standalone player
- fix NPP_Write() and propage negative lengths too (DiamondX plugin)

* Thu Nov  6 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.4-1
- fix memory leaks in NPRuntime bridge
- fix XEMBED support (workaround Gtk2 and Firefox bugs)
- fix DiamondX plugin with Konqueror4
- fix NPP_URLNotify() (Bennet Yee)
- fix NPAPI version that is exposed to the plugin

* Sun Oct 12 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.2-1
- add support for Open Solaris hosts
- add support for ARM targets (Geraint North)
- fix support for windowless plugins (Flash Player 10 rc)
- fix various bugs in RPC code (crashes and concurrent messaging)
- allow wrapping of native plugins through the -n|--native option

* Sun Jul  6 2008 Gwenole Beauchesne <gb.public@free.fr> 1.1.0-1
- add support for windowless plugins (Flash Player 10 beta 2)
- add standalone plugins player (nspluginplayer)
- restart plugins viewer on error (Martin Stransky)

* Sun Jun 29 2008 Gwenole Beauchesne <gb.public@free.fr> 1.0.0-1
- don't wrap root plugins to system locations, keep them private
- fix support for Acrobat Reader 8 (focus problems)
- fix support for mozplugger (in full debug mode)
- fix NPP_SetWindow() with a NULL NPWindow::window (WebKit)
- fix crashes with newer Flash plugin (9.0.115)
- fix build with Intel compiler and IBM XLC
- improve error handling during RPC initialization (memleaks)
- improve error handling in NPP_WriteReady() and NPP_Write()

* Sun Aug 26 2007 Gwenole Beauchesne <gb.public@free.fr> 0.9.91.5-1
- fix a memory leak in NPP_Destroy()
- fix DiamondX XEmbed example plugin
- fix focus problems (debian bug #435912)
- add support for 64-bit plugins (Martin Stransky)
- add support for newer NPAPI 0.17 functions and variables
- add support for broken 64-bit Konqueror versions (run-time detect)

* Mon Apr  2 2007 Gwenole Beauchesne <gb.public@free.fr> 0.9.91.4-1
- use anonymous sockets by default
- don't try to wrap native plugins
- require linux32 for nspluginwrapper-i386
- fix build on systems with SSP enabled by default

* Sun Mar  4 2007 Gwenole Beauchesne <gb.public@free.fr> 0.9.91.3-1
- fix printing with EMBED plugins
- fix build on Debian systems (Rob Andrews)
- use sound wrappers whenever possible on Linux (Flash Player 9)
- don't wait for dying processes (i.e. avoid hangs on NP_Shutdown)

* Fri Dec 29 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.91.2-1
- fix some rare RPC synchronisation issues (flashearth.com)
- fix hangs when the plugin exits unexpectedly (e.g. a crash)

* Tue Dec 26 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.91.1-1
- fix NPRuntime bridge (VLC plugin)
- fix Mozilla plugins dir creation on NetBSD and FreeBSD hosts
- fix potential buffer overflow in RPC marshalers
- handle empty args for plugin creation (flasharcade.com)

* Thu Dec 21 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.91-1
- add scripting support through npruntime
- add XEMBED support (mplayer plug-in)
- add NPN_RequestRead() support (Acrobat Reader)
- add support for NetBSD, FreeBSD and non-x86 Linux hosts
- fix ppc64 / ppc32 support
- fix focus problems
- fix some rare hangs (add delayed requests)
- fix libstdc++2 compat glue for broken plugins
- create user mozilla plugins dir if it does not exist yet

* Wed Nov 18 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.90.4-1
- add printing support (NPP_Print)
- add initial support for Konqueror
- fix post data to a URL (NPN_PostURL, NPN_PostURLNotify)
- reduce plugin load times
- robustify error condition (Darryl L. Miles)

* Tue Sep 19 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.90.3-1
- fix acrobat reader 7 plugin

* Sun Sep 17 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.90.2-1
- use a bidirectional communication channel

* Sun Jun  4 2006 Gwenole Beauchesne <gb.public@free.fr> 0.9.90.1-1
- relicense under GPL
- don't use QEMU on IA-64
- handle SuSE Linux Mozilla paths
- portability fixes to non-Linux platforms

* Tue Oct 25 2005 Gwenole Beauchesne <gb.public@free.fr> 0.9.90-1
- first public beta version
