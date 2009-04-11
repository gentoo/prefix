# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/c-ares/c-ares-1.5.2.ebuild,v 1.1 2008/06/01 03:55:43 dragonheart Exp $

inherit eutils

DESCRIPTION="C library that resolves names asynchronously"
HOMEPAGE="http://daniel.haxx.se/projects/c-ares/"
SRC_URI="http://daniel.haxx.se/projects/c-ares/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin8.patch
}

src_compile() {
	econf --enable-shared || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES NEWS README*
}

pkg_postinst() {
	ewarn "The soname for libares has changed in c-ares-1.4.0."
	#ewarn "If you have upgraded from that or earlier version, it is recommended to run:"
	ewarn
	ewarn "revdep-rebuild --library libcares.so.1"
	ewarn
	ewarn "This will fix linking errors caused by this change."
	echo
}
