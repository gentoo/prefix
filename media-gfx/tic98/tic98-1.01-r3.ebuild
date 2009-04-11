# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/tic98/tic98-1.01-r3.ebuild,v 1.4 2008/11/15 17:10:43 maekke Exp $

inherit eutils

DESCRIPTION="compressor for black-and-white images, in particular scanned documents"
HOMEPAGE="http://membled.com/work/mirror/tic98/"
SRC_URI="http://membled.com/work/mirror/tic98/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RESTRICT="test"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-macos.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.diff

	# respect CFLAGS and LDFLAGS
	sed -i -e "s:CFLAGS= -O -Wall -Wno-unused:CFLAGS=${CFLAGS}:" \
		-e "s:LIBS=   -lm #-L/home/singlis/linux/lib -lccmalloc -ldl:LIBS= -lm ${LDFLAGS}:" \
		-e "s:CC=	gcc -pipe :CC=$(tc-getCC):" \
		-e "s:CPP=	gcc -pipe:CPP=$(tc-getCPP):" \
		Makefile || die
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
