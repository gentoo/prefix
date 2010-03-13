# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/multitail/multitail-5.2.6.ebuild,v 1.1 2010/02/28 11:15:58 jlec Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="Tail with multiple windows"
HOMEPAGE="http://www.vanheusden.com/multitail/index.html"
SRC_URI="http://www.vanheusden.com/multitail/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug doc examples"

DEPEND="sys-libs/ncurses"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/5.2.2-as-needed.patch"
	use x86-interix && epatch "${FILESDIR}"/${P}-interix.patch
}

src_configure() {
	tc-export CC
	use debug && append-flags "-D_DEBUG"
	use prefix && sed "s:DESTDIR=/:DESTDIR=${EROOT}:g" -i Makefile
}

src_install () {
	dobin multitail || die

	insinto /etc
	doins multitail.conf || die

	dodoc Changes readme.txt thanks.txt || die
	doman multitail.1 || die

	if use examples; then
		docinto examples
		dodoc colors-example.{pl,sh} convert-{geoip,simple}.pl || die
	fi

	if use doc; then
		dohtml manual.html || die
	fi
}
