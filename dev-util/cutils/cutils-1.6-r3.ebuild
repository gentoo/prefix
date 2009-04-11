# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cutils/cutils-1.6-r3.ebuild,v 1.2 2008/11/24 23:23:51 tcunha Exp $

inherit eutils toolchain-funcs

DESCRIPTION="C language utilities"
HOMEPAGE="http://www.sigala.it/sandro/software.php#cutils"
SRC_URI="http://www.sigala.it/sandro/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}"/${PN}-infopage.patch

	epatch "${FILESDIR}"/${P}-case-insensitive.patch

	mv "${S}"/src/cdecl/cdecl.1 			\
		"${S}"/src/cdecl/cutils-cdecl.1 || die "mv cdecl failed"
	# Force rebuild of cutils.info
	rm -f "${S}"/doc/cutils.info

	sed -i "s/cdecl/cutils-cdecl/g"			\
		"${S}"/doc/cutils.texi || die "sed cutils.info failed"
	sed -i "/PROG/s/cdecl/cutils-cdecl/" 	\
		"${S}"/src/cdecl/Makefile.in || die "sed cdecl failed"
	sed -i "/Xr/s/cdecl/cutils-cdecl/"		\
		"${S}"/src/cundecl/cundecl.1 || die "sed cundecl.1 failed"
	sed -i "/Nm/s/cdecl/cutils-cdecl/"		\
		"${S}"/src/cdecl/cutils-cdecl.1 || die "sed cutils-cdecl.1 failed"
}

src_compile() {
	econf
	emake CC="$(tc-getCC)" -j1 || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CREDITS HISTORY NEWS README || die "dodoc failed"
}

pkg_postinst () {
	elog "cdecl was installed as cutils-cdecl because of a naming conflict"
	elog "with dev-util/cdecl."
}
