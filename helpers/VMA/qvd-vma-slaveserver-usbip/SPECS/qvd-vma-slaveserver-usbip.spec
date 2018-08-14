#
# spec file for package perl (Version 5.10.0)
#
# Copyright (c) 2010 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# icecream 0


Name:           qvd-vma-slaveserver-usbip
Url:            http://theqvd.com
Version:        %{qvd_version}
Release:        %{release}
Summary:        VMA helper for usbip functionality
License:        Artistic License; GPL v2 or later
Group:          Development/Languages/C
AutoReqProv:    on

%description
VMA helper for usbip functionality

Authors:
--------
    The QVD Team <qvd@qindel.com> 

%prep
rm -Rf %{buildroot}/usr

%install
mkdir -p %{buildroot}/usr/lib/qvd/bin
cp %{sourcedir}/qvd-vma-slaveserver-usbip %{buildroot}/usr/lib/qvd/bin

%files 
%defattr(4755,root,root)

/usr/lib/qvd/bin/qvd-vma-slaveserver-usbip

%changelog
* Thu Oct 27 2011 juan.zea@qindel.com
- First version
