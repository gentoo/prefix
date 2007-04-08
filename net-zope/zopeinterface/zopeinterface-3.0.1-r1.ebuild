# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-zope/zopeinterface/zopeinterface-3.0.1-r1.ebuild,v 1.3 2007/02/13 13:20:43 vapier Exp $

EAPI="prefix"

inherit distutils eutils

MY_PN="ZopeInterface"
DESCRIPTION="Standalone Zope interface library"
HOMEPAGE="http://zope.org/Products/ZopeInterface"
SRC_URI="http://www.zope.org/Products/${MY_PN}/${PV}final/${MY_PN}-${PV}.tgz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="doc"

RDEPEND=">=dev-lang/python-2.3"

S=${WORKDIR}/${MY_PN}-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-gcc4.patch
	# Rename "with": python 2.5 warns about it (will be a keyword in 2.6)
	epatch "${FILESDIR}"/${P}-with-rename.patch
}

src_install() {
	distutils_src_install
	if use doc ; then
		cp -pR $MY_PN "${ED}"/usr/share/doc/${PF}/
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
}
