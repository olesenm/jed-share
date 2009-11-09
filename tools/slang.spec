Summary: The shared library for the S-Lang extension language.
Name: slang
Version: 2.2.0
Release: 81
License: GPL
Group: System Environment/Libraries
Source: ftp://ftp.fu-berlin.de/pub/unix/misc/slang/v2.0/slang-%{version}.tar.gz
# Patch1: slang-LANG.patch
# Patch2: slang-nointerlibc2.patch
# Patch3: slang-makefile.patch
Url: http://www.s-lang.org/
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
Provides: slang = %{version}

%description
S-Lang is an interpreted language and a programming library.  The
S-Lang language was designed so that it can be easily embedded into
a program to provide the program with a powerful extension language.
The S-Lang library, provided in this package, provides the S-Lang
extension language.  S-Lang's syntax resembles C, which makes it easy
to recode S-Lang procedures in C if you need to.

%package devel
Summary: The static library and header files for development using S-Lang.
Group: Development/Libraries
Requires: slang = %{version}
Provides: slang-devel  = %{version}

%description devel
This package contains the S-Lang extension language static libraries
and header files which you'll need if you want to develop S-Lang based
applications.  Documentation which may help you write S-Lang based
applications is also included.

Install the slang-devel package if you want to develop applications
based on the S-Lang extension language.

%prep
%setup -n slang-%{version} -q
# %patch1 -p1 -b .LANG
# %patch2 -p1 -b .nointerlibc2
## %patch3 -p1 -b .makefile


%build
%configure --includedir=%{_includedir}/slang

make elf

%install
rm -rf ${RPM_BUILD_ROOT}

make DESTDIR=${RPM_BUILD_ROOT} install-elf
# remove installed documents and install them ourselves
rm -rf ${RPM_BUILD_ROOT}/usr/share/doc

%clean
rm -rf ${RPM_BUILD_ROOT}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root)
%doc COPYING changes.txt
%{_sysconfdir}/slsh*
%{_bindir}/slsh
%{_mandir}/man1/*
%{_datadir}/slsh
%{_libdir}/libslang*.so.*
%{_libdir}/slang

%files devel
%defattr(-,root,root)
%doc doc/README doc/*.txt doc/*/*.txt
%{_libdir}/libslang*.so
%{_includedir}/slang

%changelog
* Wed Jul 12 2006 Miroslav Lichvar <mlichvar@redhat.com> - 2.0.6-3
- don't build unpackaged stuff
- package just txt files from doc directory

* Tue May 23 2006 Peter Jones <pjones@redhat.com> - 2.0.6-2
- put static lib back; it is required by anaconda

* Mon May 22 2006 Miroslav Lichvar <mlichvar@redhat.com> - 2.0.6-1
- update to slang-2.0.6
- move .so.2 link to main package
- don't package static library and utf8 link
- remove requires for libtool and libtermcap
- rearrange doc files (#191583)

* Fri Feb 10 2006 Jesse Keating <jkeating@redhat.com> - 2.0.5-5.2.1
- bump again for double-long bug on ppc(64)

* Tue Feb 07 2006 Jesse Keating <jkeating@redhat.com> - 2.0.5-5.2
- rebuilt for new gcc4.1 snapshot and glibc changes

* Fri Dec 09 2005 Jesse Keating <jkeating@redhat.com>
- rebuilt

* Fri Dec 2 2005 Petr Raszyk <praszyk@redhat.com> - 2.0.5-5
- A patch by Bill Nottingham <notting@redhat.com>
  (#174761). slang-LANG.patch
  slang reads automatically sh-env-variable LANG.

* Mon Nov 21 2005 Petr Raszyk <praszyk@redhat.com> - 2.0.5-3
- Rebuild.

* Mon Nov 21 2005 Petr Raszyk <praszyk@redhat.com> - 2.0.5-1
- Upgrade to slang 20005.
- (#161536). slang-nointerlibc2.patch
- slang-makefile.patch

* Mon Oct 24 2005 Petr Raszyk <praszyk@redhat.com> - 1.4.9-23
- rebuild

* Mon Oct 24 2005 Petr Raszyk <praszyk@redhat.com> - 1.4.9-22
- libslang-utf8.so should not use the symbol __libc_enable_secure 
- (#161536). slang-nointerlibc.patch
- Additional some comments/hints for C-Frame 121

* Sun Oct 16 2005 Florian La Roche <laroche@redhat.com>
- set _filter_GLIBC_PRIVATE

* Sun Oct 16 2005 Florian La Roche <laroche@redhat.com>
- add exec perms to shared libs

* Mon Sep  5 2005 Petr Raszyk <praszyk@redhat.com> - 1.4.9-19
- One line in the patch 'slang-utf8-acs.ptach' commented out (#138445). 

* Thu Aug 18 2005 Petr Raszyk <praszyk@redhat.com> - 1.4.9-18
- Patch to resolve the problem with displaying the 'x' character
  in the latin2 mode (#139127) 

* Fri Mar 18 2005 Petr Rockai <prockai@redhat.com> - 1.4.9-17
- Patch to compile with gcc4 by Robert Scheck (#151029). (Weeird,
  probably on march 2nd the used buildroot wasn't updated with
  gcc4 yet?).

* Wed Mar 02 2005 Petr Rockai <prockai@redhat.com>
- rebuild

* Mon Feb 14 2005 Adrian Havill <havill@redhat.com>
- rebuilt

* Sun Aug 1 2004 Alan Cox <alan@redhat.com>
- fixed requires so slang-devel pulls in libtermcap-devel (#125299)

* Tue Jun 15 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Tue Mar 02 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Fri Feb 13 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Fri Dec  5 2003 Jeremy Katz <katzj@redhat.com> 1.4.9-2
- rebuild to fix libslang-utf8.so.1 symlink

* Tue Oct 28 2003 Adrian Havill <havill@redhat.com> 1.4.9-1
- big upgrade to 1.4.9
- manually redid partially rotted utf patch for sldisply.c
- no longer necessary to chmod the so files
- change copyright header to license

* Fri Jun 13 2003 Bill Nottingham <notting@redhat.com> 1.4.5-18
- fix segfault in slcurses (#97216)

* Wed Jun 04 2003 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Mon Feb 24 2003 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Fri Feb 21 2003 Jakub Jelinek <jakub@redhat.com> 1.4.5-15
- for ACS characters, take them as is, not through wcrtomb
  and assume wcwidth returns 1 for them

* Wed Jan 22 2003 Tim Powers <timp@redhat.com>
- rebuilt

* Sat Jan  4 2003 Jeff Johnson <jbj@redhat.com> 1.4.5-13
- set execute bits on library so that requires are genereted.

* Wed Nov 27 2002 Tim Powers <timp@redhat.com> 1.4.5-12
- remove unpackaged files from the buildroot
- lib64'ize

* Wed Jul 24 2002 Bill Nottingham <notting@redhat.com> 1.4.5-11
- fix write-before-beginning-of-string in SLsmg_write_nwchars

* Tue Jul  9 2002 Bill Nottingham <notting@redhat.com> 1.4.5-10
- fix segfault in odd environments

* Mon Jul  8 2002 Bill Nottingham <notting@redhat.com> 1.4.5-9
- tweak UTF-8 linedrawing patch slightly; add README describing some of
  the changes
- fix a utee/dtee typo

* Wed Jun 26 2002 Bill Nottingham <notting@redhat.com> 1.4.5-7
- add patch to support ACS linedrawing characters in UTF-8

* Fri Jun 21 2002 Tim Powers <timp@redhat.com>
- automated rebuild

* Wed Jun 12 2002 Bill Nottingham <notting@redhat.com> 1.4.5-5
- removed keymap patch (#59171)
- added Debian utf8 patch

* Thu May 23 2002 Tim Powers <timp@redhat.com>
- automated rebuild

* Tue Mar  5 2002 Bill Nottingham <notting@redhat.com>
- fix symlink & ia64 fubarness

* Mon Mar  4 2002 Bill Nottingham <notting@redhat.com>
- update to 1.4.5

* Tue Jun 26 2001 Florian La Roche <Florian.LaRoche@redhat.de>
- add link from library major version number

* Mon Jun 25 2001 Bill Nottingham <notting@redhat.com>
- added patch to fix Alt/Meta key handling (originally from mutt,
  <jorton@btconnect.com>)

* Fri Jun  1 2001 Oliver Paukstadt <oliver.paukstadt@millenux.com>
- forced to use RPM_OPT_FLAGS for ELF_CFLAGS too

* Mon Mar 12 2001 Bill Nottingham <notting@redhat.com>
- update to 1.4.4

* Tue Feb 27 2001 Bill Nottingham <notting@redhat.com>
- have slang-devel require slang = %%{version}

* Tue Aug 29 2000 Bill Nottingham <notting@redhat.com>
- update to 1.4.2

* Wed Jul 12 2000 Prospector <bugzilla@redhat.com>
- automatic rebuild

* Sat Jun 17 2000 Matt Wilson <msw@redhat.com>
- added defattr

* Sat Jun 10 2000 Bill Nottingham <notting@redhat.com>
- rebuild, FHS stuff

* Fri Apr 28 2000 Bill Nottingham <notting@redhat.com>
- autoconf fix for ia64

* Mon Apr 24 2000 Bill Nottingham <notting@redhat.com>
- update to 1.4.1

* Wed Mar 29 2000 Bill Nottingham <notting@redhat.com>
- fix background color problem with newt

* Thu Mar  2 2000 Bill Nottingham <notting@redhat.com>
- resurrect for the devel tree

* Sun Mar 21 1999 Cristian Gafton <gafton@redhat.com> 
- auto rebuild in the new build environment (release 4)

* Wed Oct 21 1998 Bill Nottingham <notting@redhat.com>
- libslang.so goes in -devel

* Sun Jun 07 1998 Prospector System <bugs@redhat.com>

- translations modified for de

* Sat Jun  6 1998 Jeff Johnson <jbj@redhat.com>
- updated to 1.2.2 with buildroot.

* Tue May 05 1998 Prospector System <bugs@redhat.com>
- translations modified for de, fr, tr

* Sat Apr 18 1998 Erik Troan <ewt@redhat.com>
- rebuilt to find terminfo in /usr/share

* Tue Oct 14 1997 Donnie Barnes <djb@redhat.com>
- spec file cleanups

* Mon Sep 1 1997 Donnie Barnes <djb@redhat.com>
- upgraded to 0.99.38 (will it EVER go 1.0???)
- all patches removed (all appear to be in this version)

* Thu Jun 19 1997 Erik Troan <ewt@redhat.com>
- built against glibc

