# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/aget/aget-0.4.ebuild,v 1.12 2008/02/04 17:07:10 grobian Exp $

EAPI="prefix"

inherit eutils

IUSE=""
DEB_PATCH="${PN}_${PV}-4.diff"
DESCRIPTION="multithreaded HTTP download accelerator"
HOMEPAGE="http://www.enderunix.org/aget/"
SRC_URI="http://www.enderunix.org/${PN}/${P}.tar.gz
	mirror://debian/pool/main/a/${PN}/${DEB_PATCH}.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${DEB_PATCH}
	sed -i "/^CFLAGS/s:-g:${CFLAGS}:" Makefile
}

src_compile() {
	emake || die
}

src_install() {
	dobin aget || die
	dodoc AUTHORS ChangeLog README* THANKS TODO
	doman debian/aget.1
}
