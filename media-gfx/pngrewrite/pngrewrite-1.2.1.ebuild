# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pngrewrite/pngrewrite-1.2.1.ebuild,v 1.10 2007/07/12 04:08:47 mr_bones_ Exp $

EAPI="prefix"

DESCRIPTION="A utility which reduces large palettes in PNG images"
HOMEPAGE="http://entropymine.com/jason/pngrewrite/"
SRC_URI="http://entropymine.com/jason/pngrewrite/${P}.zip"

DEPEND="app-arch/unzip
	media-libs/libpng
	sys-libs/zlib"

RDEPEND="media-libs/libpng
	sys-libs/zlib"

SLOT="0"
LICENSE="public-domain"
KEYWORDS="~x86-linux ~ppc-macos"

IUSE=""

S="${WORKDIR}"

src_compile () {
	gcc -o pngrewrite pngrewrite.c -lpng -lz $CFLAGS || die
}

src_install () {
	dobin pngrewrite
}
