# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libperl/libperl-5.10.1.ebuild,v 1.20 2010/11/13 16:05:05 armin76 Exp $

inherit multilib

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="1"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

PDEPEND=">=dev-lang/perl-5.10.1"

pkg_postinst() {
	if [[ $(readlink "${EROOT}/usr/$(get_libdir)/libperl$(get_libname)") == libperl$(get_libname 1) ]] ; then
		einfo "Removing stale symbolic link: ${EROOT}usr/$(get_libdir)/libperl$(get_libname)"
		rm "${EROOT}"/usr/$(get_libdir )/libperl$(get_libname)
	fi
}
