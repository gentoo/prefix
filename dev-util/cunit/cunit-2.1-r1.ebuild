# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cunit/cunit-2.1-r1.ebuild,v 1.4 2009/01/10 16:14:10 armin76 Exp $

inherit eutils autotools

MY_PN='CUnit'
MY_PV="${PV}-0"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="CUnit - C Unit Test Framework"
SRC_URI="mirror://sourceforge/cunit/${MY_P}-src.tar.gz"
HOMEPAGE="http://cunit.sourceforge.net"

DEPEND="virtual/libc"
SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -e "/^docdir/d" -i doc/Makefile.am
	sed -e '/^dochdrdir/{s:$(prefix)/doc/@PACKAGE@:$(docdir):}' \
		-i doc/headers/Makefile.am
	eautoreconf
}

src_compile() {
	econf --docdir="${EPREFIX}"/usr/share/doc/${PF}
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS NEWS README ChangeLog
}
