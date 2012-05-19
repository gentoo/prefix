# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/aview/aview-1.3.0_rc1-r2.ebuild,v 1.1 2011/02/23 17:56:58 signals Exp $

inherit base

MY_P=${P/_/}
S=${WORKDIR}/${MY_P/rc*/}
DESCRIPTION="An ASCII Image Viewer"
SRC_URI="mirror://sourceforge/aa-project/${MY_P}.tar.gz"
HOMEPAGE="http://aa-project.sourceforge.net/aview/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=media-libs/aalib-1.4_rc4"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-asciiview.patch
	"${FILESDIR}"/${P}-includes.patch
)

src_unpack() {
	base_src_unpack

	sed -i -e 's:#include <malloc.h>:#include <stdlib.h>:g' "${S}"/*.c
	sed -i -e '1c\#!/usr/bin/env bash' "${S}"/asciiview
}

src_compile() {
	econf || die
	make aview || die
}

src_install() {
	into /usr
	dobin aview asciiview

	doman *.1
	dodoc ANNOUNCE ChangeLog README TODO
}
