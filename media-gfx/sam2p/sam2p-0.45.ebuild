# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/sam2p/sam2p-0.45.ebuild,v 1.9 2007/12/18 19:18:26 jer Exp $

EAPI="prefix"

inherit toolchain-funcs eutils

DESCRIPTION="Utility to convert raster images to EPS, PDF and many others"
HOMEPAGE="http://www.inf.bme.hu/~pts/sam2p/"
# The author refuses to distribute
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="gif"
DEPEND="dev-lang/perl"
RDEPEND="virtual/libc"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# force an US locale, otherwise make Makedep will bail out
	epatch "${FILESDIR}"/${P}-locales.patch
}

src_compile() {
	# Makedep fails with distcc
	if has distcc ${FEATURES}; then
		die "disable FEATURES=distcc"
	fi
	econf --enable-lzw $(use_enable gif) || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	einstall
	dodoc README
}
