# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/colorcvs/colorcvs-1.4.ebuild,v 1.9 2008/01/26 19:04:55 grobian Exp $

inherit eutils

DESCRIPTION="A tool based on colorgcc to beautify cvs output"
HOMEPAGE="http://www.hakubi.us/colorcvs/"
SRC_URI="http://www.hakubi.us/colorcvs/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=""
RDEPEND="dev-lang/perl
	dev-util/cvs"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
}

src_install() {
	exeinto /usr/bin
	doexe colorcvs
	dodoc colorcvsrc-sample COPYING
}
