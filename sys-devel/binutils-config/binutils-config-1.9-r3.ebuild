# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r3.ebuild,v 1.1 2006/11/26 13:40:14 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utility to change the binutils version being used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=sys-apps/findutils-4.2"

src_unpack() {
	cp "${FILESDIR}"/${PN}-${PV} "${T}"/
	eprefixify "${T}"/${PN}-${PV}
}

src_install() {
	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8
}
