# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Darwin assembler as(1) and static linker ld(1)"
HOMEPAGE="http://www.opendarwin.org/projects/odcctools/"
SRC_URI="http://dev.gentoo.org/~kito/distfiles/${P}.tar.bz2"
#SRC_URI="http://www.opendarwin.org/downloads/${P}.tar.bz2"

LICENSE="APSL-2"
SLOT="0"

KEYWORDS="~ppc-macos"

IUSE="build"

DEPEND=""
#RDEPEND=""

S=${WORKDIR}/${P}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die
	use build && rm -rf ${ED}/usr/share/man
}
