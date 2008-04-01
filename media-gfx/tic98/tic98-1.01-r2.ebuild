# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/tic98/tic98-1.01-r2.ebuild,v 1.1 2008/03/31 19:45:24 maekke Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="compressor for black-and-white images, in particular scanned documents"
HOMEPAGE="http://membled.com/work/mirror/tic98/"
SRC_URI="http://membled.com/work/mirror/tic98/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-macos.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.diff
}

src_compile() {
	emake all || die
	emake all2 || die
}

src_install() {
	dodir /usr/bin
	emake BIN="${ED}"usr/bin install || die

	# collision with media-gfx/netpbm, see bug #207534
	rm "${ED}"/usr/bin/pbmclean || die
}
