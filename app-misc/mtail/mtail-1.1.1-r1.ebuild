# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mtail/mtail-1.1.1-r1.ebuild,v 1.13 2005/06/05 11:52:22 hansmi Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="tail workalike, that performs output colourising"
HOMEPAGE="http://matt.immute.net/src/mtail/"
SRC_URI="http://matt.immute.net/src/mtail/mtail-${PV}.tgz
	http://matt.immute.net/src/mtail/mtailrc-syslog.sample"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python"

src_unpack() {
	unpack ${P}.tgz
	cd ${S}
	epatch ${FILESDIR}/${P}-remove-blanks.patch
}

src_install() {
	dobin mtail
	dodoc CHANGES mtailrc.sample README ${DISTDIR}/mtailrc-syslog.sample
}
