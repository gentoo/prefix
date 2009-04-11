# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/dvdbackup/dvdbackup-0.1.1-r2.ebuild,v 1.9 2007/11/27 12:38:23 zzam Exp $

inherit toolchain-funcs eutils

DESCRIPTION="Backup content from DVD to hard disk"
HOMEPAGE="http://dvd-create.sourceforge.net/"
SRC_URI="http://dvd-create.sourceforge.net/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND="media-libs/libdvdread"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PV}-debian-FPE.patch"
	epatch "${FILESDIR}/${P}-mkdir.patch"
	epatch "${FILESDIR}/${P}-dvdread.patch"
}

src_compile() {
	$(tc-getCC) ${LDFLAGS} ${CFLAGS} -I/usr/include/dvdread \
		-o dvdbackup src/dvdbackup.c -ldvdread \
		|| die "compile failed"
}

src_install() {
	dobin dvdbackup || die
	dodoc README
}
