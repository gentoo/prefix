# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/sysfsutils/sysfsutils-2.1.0.ebuild,v 1.9 2007/12/16 12:34:09 armin76 Exp $

inherit multilib

DESCRIPTION="System Utilities Based on Sysfs"
HOMEPAGE="http://linux-diag.sourceforge.net/Sysfsutils.html"
SRC_URI="mirror://sourceforge/linux-diag/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS CREDITS ChangeLog NEWS README TODO docs/libsysfs.txt

	# We do not distribute this
	rm -f "${ED}"/usr/bin/dlist_test

	# Move shared libs to /
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/lib*$(get_libname)* "${ED}"/$(get_libdir)/ || die
	gen_usr_ldscript libsysfs$(get_libname)
}
