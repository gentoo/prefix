# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/lush/lush-1.2.1.ebuild,v 1.1 2007/09/18 17:28:55 hkbst Exp $

inherit eutils autotools

DESCRIPTION="Lush is the Lisp User Shell"
HOMEPAGE="http://lush.sourceforge.net/"
SRC_URI="mirror://sourceforge/lush/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="X"

DEPEND="X? ( x11-libs/libX11 x11-libs/libICE x11-libs/libSM )"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}; cd "${S}"
	epatch "${FILESDIR}"/${P}-ctype.patch
#	cp aclocal.m4 aclocal.m4.old
#	sed "/dnl @synopsis AC_CC_OPTIMIZE/,/^])/d" -i aclocal.m4
#	sed "/.*AC_CHECK_CC_OPT.*OPTS.*/d" -i aclocal.m4
#	sed "/AC_CC_OPTIMIZE/d" -i configure.ac
	epatch ${FILESDIR}/aclocal.m4.patch
#	diff -u aclocal.m4.old aclocal.m4
	eautoreconf
}

src_compile() {
	econf $(use_with X X)
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR=${D} install || die "emake install failed"
}
