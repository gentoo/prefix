# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/aget/aget-0.4.ebuild,v 1.13 2009/01/14 03:27:27 vapier Exp $

inherit eutils

DEB_PATCH="${PN}_${PV}-4.diff"
DESCRIPTION="multithreaded HTTP download accelerator"
HOMEPAGE="http://www.enderunix.org/aget/"
SRC_URI="http://www.enderunix.org/${PN}/${P}.tar.gz
	mirror://debian/pool/main/a/${PN}/${DEB_PATCH}.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${DEB_PATCH}
	sed -i \
		-e '/^CFLAGS/s:=.*:+= -Wall $(CPPFLAGS):' \
		-e '/^LDFLAGS/s:=:+=:' \
		Makefile
	sed -i '/_XOPEN_SOURCE/d' Head.c
}

src_install() {
	dobin aget || die
	dodoc AUTHORS ChangeLog README* THANKS TODO
	doman debian/aget.1
}
