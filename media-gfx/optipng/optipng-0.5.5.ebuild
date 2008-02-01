# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/optipng/optipng-0.5.5.ebuild,v 1.2 2008/01/31 18:07:45 nyhm Exp $

EAPI="prefix"

DESCRIPTION="Compress PNG files without affecting image quality"
HOMEPAGE="http://optipng.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "s:-O2:${CFLAGS}:" \
		-e "s:-s:${LDFLAGS}:" \
		src/scripts/gcc.mak \
		lib/libpng/scripts/makefile.gcc \
		lib/pngxtern/scripts/gcc.mak \
		|| die "sed failed"
}

src_compile() {
	emake -C src -f scripts/gcc.mak || die "emake failed"
}

src_install() {
	dobin src/optipng || die "dobin failed"
	dodoc README.txt doc/*.txt
	dohtml doc/*.html
	doman man/optipng.1
}
