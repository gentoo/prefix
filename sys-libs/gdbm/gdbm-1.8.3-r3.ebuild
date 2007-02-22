# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gdbm/gdbm-1.8.3-r3.ebuild,v 1.3 2007/02/17 22:45:04 grobian Exp $

EAPI="prefix"

inherit eutils libtool multilib

DESCRIPTION="Standard GNU database libraries"
HOMEPAGE="http://www.gnu.org/software/gdbm/gdbm.html"
SRC_URI="mirror://gnu/gdbm/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="berkdb"

DEPEND="berkdb? ( sys-libs/db )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-fix-install-ownership.patch #24178
	epatch "${FILESDIR}"/${P}-compat-linking.patch #165263
	elibtoolize
}

src_compile() {
	use berkdb || export ac_cv_lib_dbm_main=no ac_cv_lib_ndbm_main=no
	econf --includedir=${EPREFIX}/usr/include/gdbm || die
	emake || die
}

src_install() {
	emake -j1 INSTALL_ROOT="${D}" install install-compat || die
	mv "${ED}"/usr/include/gdbm/gdbm.h "${ED}"/usr/include/ || die
	dodoc ChangeLog NEWS README
}

pkg_preinst() {
	preserve_old_lib libgdbm.so.2 #32510
}

pkg_postinst() {
	preserve_old_lib_notify libgdbm.so.2 #32510
}
