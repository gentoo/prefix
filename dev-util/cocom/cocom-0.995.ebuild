# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cocom/cocom-0.995.ebuild,v 1.3 2005/11/05 20:05:33 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Tool set oriented onto the creation of compilers, cross-compilers, interpreters, and other language processors"
HOMEPAGE="http://cocom.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND="virtual/libc"

src_unpack() {
	unpack "${A}"
	epatch "${FILESDIR}/${P}"-gcc4.patch
}

src_compile() {
	econf || die
	emake -j1 || die "emake failed"
}

src_install() {
	make install DESTDIR=${D} || die
}
