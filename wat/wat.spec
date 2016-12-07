Name:           qvd-wat
Version:        4.0
Release:        1%{?dist}
Summary:        Pruebas de empaquetado para SLES12

Group:        	Productivity/Networking/Web/Utilities
License:        GPL 3
URL:            http://theqvd.com
Source0:       	qvd-wat.tgz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

Requires: perl-QVD-API

%description
Web Administration Tool for qvd

%prep
%setup -q


%build

make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
/usr/lib/qvd/wat
%defattr(-,root,root,-)
%doc



%changelog
* Fri Nov 25 2016 QVD Team <qvd@qindel.com>
- Initial Release
