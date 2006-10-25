# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r1.ebuild,v 1.1 2006/08/27 18:03:47 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utility to change the binutils version being used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	cp "${FILESDIR}"/${PN}-${PV} "${T}"/ 
	cd "${T}"
	epatch "${FILESDIR}"/${PN}-${PV}-prefix.patch
	eprefixify "${T}"/${PN}-${PV}
}

src_install() {
	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8
}
