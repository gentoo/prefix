# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/httpup/httpup-0.3.2.ebuild,v 1.4 2009/08/25 19:54:09 vostorga Exp $

inherit eutils toolchain-funcs

DESCRIPTION="synchronisation tool for http file repositories"
HOMEPAGE="http://clc.berlios.de/projects/httpup/"
SRC_URI="http://jw.tks6.net/files/crux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="net-misc/curl"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
	sed -i \
		-e 's:g++:$(CXX) $(CFLAGS) $(LDFLAGS):' \
		Makefile
	epatch "${FILESDIR}"/${P}-gcc43.patch
	epatch "${FILESDIR}"/${P}-gcc44.patch
}

src_compile() {
	emake CXX="$(tc-getCXX)" || die "make failed"
}

src_install() {
	dobin httpup httpup-repgen httpup-repgen2 || die "dobin"
	doman *.8
	dodoc AUTHORS README TODO ChangeLog httpup.conf.example
}
