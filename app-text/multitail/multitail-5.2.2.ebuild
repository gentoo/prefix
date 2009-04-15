# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/multitail/multitail-5.2.2.ebuild,v 1.5 2009/04/11 18:00:01 nixnut Exp $

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="Tail with multiple windows."
HOMEPAGE="http://www.vanheusden.com/multitail/index.html"
SRC_URI="http://www.vanheusden.com/multitail/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="sys-libs/ncurses"

src_unpack() {
	unpack ${A}
	cd "${S}"

	use x86-interix && epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	tc-export CC
	use debug && append-flags "-D_DEBUG"
	use prefix && sed "s:DESTDIR=/:DESTDIR=${EROOT}:g" -i Makefile
	emake all || die "make failed"
}

src_install () {
	dobin multitail
	insinto /etc
	doins multitail.conf
	insinto /etc/multitail/
	doins colors-example.pl colors-example.sh convert-geoip.pl convert-simple.pl
	dodoc Changes readme.txt thanks.txt
	dohtml manual.html manual-nl.html
	doman multitail.1
}
