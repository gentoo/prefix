# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cunit/cunit-2.0.ebuild,v 1.6 2007/08/13 20:46:58 dertobi123 Exp $

inherit eutils autotools

DESCRIPTION="CUnit - C Unit Test Framework"
SRC_URI="mirror://sourceforge/cunit/${P}-1.tar.gz"
HOMEPAGE="http://cunit.sourceforge.net"
DEPEND="virtual/libc"
SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
S=${WORKDIR}/CUnit-${PV}-1

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-ncurses.patch
	eautoreconf
}

src_compile() {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install() {
	einstall || die "make install failed"
	dodoc AUTHORS COPYING INSTALL NEWS README ChangeLog
}
