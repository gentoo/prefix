# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mosml/mosml-2.01-r1.ebuild,v 1.1 2008/06/06 01:26:53 darkside Exp $

EAPI="prefix"

inherit eutils

S="${WORKDIR}/${PN}/src"
DESCRIPTION="Moscow ML - a lightweight implementation of Standard ML (SML)"
SRC_URI="http://www.itu.dk/people/sestoft/mosml/mos201src.tar.gz"
HOMEPAGE="http://www.itu.dk/people/sestoft/mosml.html"
LICENSE="GPL-2"
DEPEND=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
SLOT="0"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-malloc.patch" #154859
	sed -i -e "s|^CPP=/lib/cpp|CPP=${EPREFIX}/usr/bin/cpp|" Makefile.inc
}

src_compile() {
	emake MOSMLHOME="${EPREFIX}"/opt/mosml world || die
}

src_install () {

	make MOSMLHOME="${ED}"/opt/mosml install || die
	rm "${ED}"/opt/mosml/lib/camlrunm # This is a bad symlink
	echo "#!${EPREFIX}/opt/mosml/bin/camlrunm" > "${ED}"/opt/mosml/lib/header

	dodoc  ../README
	into   /usr/bin
	dosym  /opt/mosml/bin/mosml     /usr/bin/mosml
	dosym  /opt/mosml/bin/mosmlc    /usr/bin/mosmlc
	dosym  /opt/mosml/bin/mosmllex  /usr/bin/mosmllex
	dosym  /opt/mosml/bin/mosmlyac  /usr/bin/mosmlyac
	dosym  /opt/mosml/bin/camlrunm  /usr/bin/camlrunm
	dosym  /opt/mosml/bin/camlrunm  /opt/mosml/lib/camlrunm

}
