# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/uulib/uulib-0.5.20.ebuild,v 1.19 2008/01/25 21:11:25 grobian Exp $

EAPI="prefix"

MY_P=uudeview-${PV}

DESCRIPTION="library that supports Base64 (MIME), uuencode, xxencode and binhex coding"
HOMEPAGE="http://www.fpx.de/fp/Software/UUDeview/"
SRC_URI="http://www.fpx.de/fp/Software/UUDeview/download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S=${WORKDIR}/${MY_P}/${PN}

src_install() {
	dolib.a libuu.a
	insinto /usr/include
	doins uudeview.h
}
