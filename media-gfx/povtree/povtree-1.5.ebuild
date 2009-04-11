# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/povtree/povtree-1.5.ebuild,v 1.7 2008/01/15 18:23:46 grobian Exp $

inherit prefix

S="${WORKDIR}"
MY_P="${PN}${PV}"
DESCRIPTION="Tree generator for POVray based on TOMTREE macro"
HOMEPAGE="http://propro.ru/go/Wshop/povtree/povtree.html"
SRC_URI="http://propro.ru/go/Wshop/povtree/${MY_P}.zip"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
LICENSE="as-is"
SLOT="0"
IUSE=""

RDEPEND=">=virtual/jre-1.3"
DEPEND="app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${T}"
	cp "${FILESDIR}"/povtree .
	eprefixify "${T}"/povtree
}

src_install() {
	# wrapper
	dobin "${T}"/povtree || die "dobin failed"
	# package
	insinto /usr/lib/povtree
	doins povtree.jar || die "doins failed"
	dodoc TOMTREE-${PV}.inc help.jpg || die "dodoc failed"
}
