# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/bin2iso/bin2iso-19b-r2.ebuild,v 1.2 2005/09/12 17:59:52 grobian Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="converts RAW format (.bin/.cue) files to ISO/WAV format"
HOMEPAGE="http://users.andara.com/~doiron/bin2iso/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	edos2unix *.c
	epatch "${FILESDIR}"/${P}-sanity-checks.patch
}

src_compile() {
	$(tc-getCC) bin2iso19b_linux.c -o ${PN} ${CFLAGS} ${LDFLAGS} || die "compile failed"
}

src_install() {
	dobin ${PN} || die "dobin failed"
	dodoc readme.txt
}
