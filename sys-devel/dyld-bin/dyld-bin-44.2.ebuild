# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Darwin assembler as(1) and static linker ld(1)"
HOMEPAGE="http://www.opendarwin.org/projects/odcctools/"
SRC_URI="http://dev.gentoo.org/~kito/distfiles/${P}.tar.gz"

LICENSE="APSL-2"
SLOT="0"

KEYWORDS="~ppc-macos"

IUSE="build"

DEPEND=""

src_compile() {
	:
}

src_install() {
	dodir /usr
	cp -pPR ${S}/usr ${D}/
}
