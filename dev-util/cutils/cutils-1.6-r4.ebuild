# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cutils/cutils-1.6-r4.ebuild,v 1.5 2012/03/18 17:50:44 armin76 Exp $

EAPI=4

inherit eutils toolchain-funcs

DESCRIPTION="C language utilities"
HOMEPAGE="http://www.sigala.it/sandro/software.php#cutils"
SRC_URI="http://www.sigala.it/sandro/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=""
DEPEND="sys-devel/flex"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-infopage.patch

	epatch "${FILESDIR}"/${P}-case-insensitive.patch

	mv "${S}"/src/cdecl/cdecl.1 			\
		"${S}"/src/cdecl/cutils-cdecl.1 || die
	# Force rebuild of cutils.info
	rm -f "${S}"/doc/cutils.info || die

	sed -i "s/cdecl/cutils-cdecl/g"			\
		"${S}"/doc/cutils.texi || die
	sed -i "/PROG/s/cdecl/cutils-cdecl/" 	\
		"${S}"/src/cdecl/Makefile.in || die
	sed -i "/Xr/s/cdecl/cutils-cdecl/"		\
		"${S}"/src/cundecl/cundecl.1 || die
	sed -i "/Nm/s/cdecl/cutils-cdecl/"		\
		"${S}"/src/cdecl/cutils-cdecl.1 || die
}

src_compile() {
	emake CC="$(tc-getCC)" -j1
}

src_install () {
	emake DESTDIR="${D}" install
	dodoc CREDITS HISTORY NEWS README
}

pkg_postinst () {
	elog "cdecl was installed as cutils-cdecl because of a naming conflict"
	elog "with dev-util/cdecl."
}
