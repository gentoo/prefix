# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/mdf2iso/mdf2iso-0.3.0-r1.ebuild,v 1.3 2006/12/20 02:56:03 pylon Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Alcohol 120% bin image to ISO image file converter"
HOMEPAGE="http://mdf2iso.berlios.de/"
SRC_URI="http://download.berlios.de/${PN}/${P}-src.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND="virtual/libc"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${P}-bigfiles.patch
}

src_install() {
	dodoc ChangeLog
	dobin src/${PN} || die "dobin failed"
}
