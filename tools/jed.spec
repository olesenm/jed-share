Summary: Fast, compact editor based on the S-Lang screen library
Name: jed
Version: 0.99.20
Release: 71
License: GPL
Group: Applications/Editors
Source0: ftp://space.mit.edu/pub/davis/jed/v0.99/jed-%{version}.tar.gz
URL: http://www.jedsoft.org/jed/
Patch1: jed-etc.patch
Obsoletes: jed-common jed-xjed
Provides: jed-common jed-xjed
Requires: slang-slsh
# BuildRequires: slang-devel >= 2.0, autoconf, libselinux-devel
BuildRequires: slang-devel >= 2.0, autoconf
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Jed is a fast, compact editor based on the S-Lang screen library.  Jed
features include emulation of the Emacs, EDT, WordStar and Brief
editors; support for extensive customization with slang macros,
colors, keybindings; and a variety of programming modes with syntax
highlighting.

You should install jed if you've used it before and you like it, or if
you haven't used any text editors before and you're still deciding
what you'd like to use.

%prep
%setup -n jed-%{version} -q
%patch1 -p1
find doc -type f -exec chmod a-x {} \;

%build
export JED_ROOT="%{_datadir}/jed"
unset  JED_LIBRARY
%if "%{_lib}" == "lib64"
%configure --with-slanginc=/usr/include/slang --with-slanglib=/usr/lib64
%else
%configure
%endif
make %{?_smp_mflags} all xjed

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

unset JED_LIBRARY
JED_ROOT=$RPM_BUILD_ROOT%{_datadir}/jed $RPM_BUILD_ROOT%{_bindir}/jed -batch -n -l preparse.sl </dev/null

rm -f $RPM_BUILD_ROOT%{_mandir}/man*/rgrep*

rm -rf $RPM_BUILD_ROOT%{_datadir}/jed/doc/{txt,manual,README}
rm -rf $RPM_BUILD_ROOT%{_datadir}/jed/bin
rm -rf $RPM_BUILD_ROOT%{_datadir}/info

sed -i "s|JED_ROOT|%{_datadir}/jed|g" $RPM_BUILD_ROOT/%{_mandir}/man1/jed.1

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc COPYING COPYRIGHT doc INSTALL INSTALL.unx README changes.txt
%{_bindir}/*
%{_mandir}/man1/jed.*
%{_datadir}/jed

%changelog
* Mon Jun  5 2006 Bill Nottingham <notting@redhat.com> - 0.99.18-4
- get rid of rpath on x86_64
- remove install-info prereq
- add provides for things obsoleted

* Fri Jun  2 2006 Bill Nottingham <notting@redhat.com> - 0.99.18-3
- various spec cleanups (#189374)

* Tue May  9 2006 Bill Nottingham <notting@redhat.com> - 0.99.18-2
- don't do all the installation by hand
- get help files installed
- fix JED_ROOT references in man page
- make /etc/jed.rc (as specified in man page) work

* Tue Apr 18 2006 Bill Nottingham <notting@redhat.com> - 0.99.18-1
- update to 0.99.18

* Mon Feb 13 2006 Bill Nottingham <notting@redhat.com> - 0.99.17-0.pre135.3
- bump for rebuild

* Mon May  9 2005 Bill Nottingham <notting@redhat.com> 0.99.16-10
- don't forcibly strip binary, fixes debuginfo generation

* Fri Mar  4 2005 Bill Nottingham <notting@redhat.com> 0.99.16-8
- bump release

* Sun Feb 27 2005 Florian La Roche <laroche@redhat.com>
- Copyright: -> License

* Sat Sep 25 2004 Bill Nottingham <notting@redhat.com> 0.99.16-6
- add SELinux support

* Tue Jun 15 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Tue May  4 2004 Bill Nottingham <notting@redhat.com> 0.99.16-4
- remove info page (#115826)

* Fri Feb 13 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Wed Jun 04 2003 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Thu May 22 2003 Bill Nottingham <notting@redhat.com> 0.99.16-1
- update to 0.99.16

* Wed Jan 22 2003 Tim Powers <timp@redhat.com>
- rebuilt

* Thu Dec 12 2002 Tim Powers <timp@redhat.com> 0.99.15-4
- rebuild on all arches

* Thu Jul 25 2002 Bill Nottingham <notting@redhat.com> 0.99.15-3
- obsolete xjed subpackage to help upgrades (ick)

* Wed Jul 24 2002 Bill Nottingham <notting@redhat.com> 0.99.15-2
- remove xjed subpackage, collapse -common into main package

* Mon Jun 24 2002 Bill Nottingham <notting@redhat.com> 0.99.15-1
- update to 0.99.15

* Fri Jun 21 2002 Tim Powers <timp@redhat.com>
- automated rebuild

* Fri Jun 14 2002 Bill Nottingham <notting@redhat.com> 0.99.14-5
- rebuild against new slang

* Thu May 23 2002 Tim Powers <timp@redhat.com>
- automated rebuild

* Wed Jan 09 2002 Tim Powers <timp@redhat.com>
- automated rebuild

* Fri Jul 20 2001 Bill Nottingham <notting@redhat.com>
- add buildprereq (#49505)

* Thu Jun 21 2001 Bill Nottingham <notting@redhat.com>
- update to 0.99.14

* Mon May 14 2001 Preston Brown <pbrown@redhat.com>
- rgrep is obsolete, package removed.

* Thu Dec 28 2000 Bill Nottingham <notting@redhat.com>
- do the long-needed update to 0.99 series

* Thu Jul 13 2000 Prospector <bugzilla@redhat.com>
- automatic rebuild

* Sat Jun 10 2000 Bill Nottingham <notting@redhat.com>
- rebuild, move the man pages, etc.

* Mon Feb 07 2000 Preston Brown <pbrown@redhat.com>
- wmconfig -> desktop

* Sat Feb 05 2000 Cristian Gafton <gafton@redhat.com>
- add info entry

* Thu Feb  3 2000 Bill Nottingham <notting@redhat.com>
- handle compressed man pages
- add install-info scripts

* Sun Mar 21 1999 Cristian Gafton <gafton@redhat.com>
- auto rebuild in the new build environment (release 2)

* Thu Oct 29 1998 Bill Nottingham <notting@redhat.com>
- update to 0.98.7 for Raw Hide
- split off lib stuff into jed-common

* Mon Oct  5 1998 Jeff Johnson <jbj@redhat.com>
- change rgep group tag, same as grep.

* Sat Aug 15 1998 Jeff Johnson <jbj@redhat.com>
- build root

* Thu May 07 1998 Prospector System <bugs@redhat.com>
- translations modified for de, fr, tr

* Wed Apr 15 1998 Erik Troan <ewt@redhat.com>
- built against new ncurses

* Mon Nov  3 1997 Michael Fulbright <msf@redhat.com>
- added wmconfig entry for xjed

* Tue Oct 21 1997 Michael Fulbright <msf@redhat.com>
- updated to 0.98.4
- included man pages in file lists

* Thu Jul 10 1997 Erik Troan <ewt@redhat.com>
- built against glibc
