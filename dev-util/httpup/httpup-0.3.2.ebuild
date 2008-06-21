# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/httpup/httpup-0.3.2.ebuild,v 1.3 2008/06/20 14:07:12 loki_val Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="synchronisation tool for http file repositories"
HOMEPAGE="http://clc.berlios.de/projects/httpup/"
SRC_URI="http://jw.tks6.net/files/crux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="net-misc/curl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
	sed -i \
		-e 's:g++:$(CXX) $(CFLAGS) $(LDFLAGS):' \
		Makefile
	epatch "${FILESDIR}"/${P}-gcc43.patch
}

src_install() {
	dobin httpup httpup-repgen httpup-repgen2 || die "dobin"
	doman *.8
	dodoc AUTHORS README TODO ChangeLog httpup.conf.example
}
