# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/extract-xiso/extract-xiso-2.5.ebuild,v 1.1 2006/03/13 19:18:31 chrb Exp $

EAPI="prefix"

inherit eutils

MY_PV=${PV/_beta/b}
DESCRIPTION="Tool for extracting and creating optimised Xbox ISO images"
HOMEPAGE="http://sourceforge.net/projects/extract-xiso"
SRC_URI="mirror://sourceforge/extract-xiso/${PN}_v${MY_PV}_src.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	sed -i -e "s:-O2:${CFLAGS}:g" ${S}/Makefile || die "sed failed"
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dobin extract-xiso || die "dobin failed"
}
