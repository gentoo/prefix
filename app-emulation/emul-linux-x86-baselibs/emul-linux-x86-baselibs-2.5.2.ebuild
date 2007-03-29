# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-baselibs/emul-linux-x86-baselibs-2.5.2.ebuild,v 1.1 2006/09/06 18:31:57 blubb Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Base libraries for emulation of 32bit x86 on amd64"
SRC_URI="mirror://gentoo/${P}.tar.bz2
		http://dev.gentoo.org/~blubb/${P}.tar.bz2"
HOMEPAGE="http://www.gentoo.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}

RDEPEND="app-emulation/emul-linux-x86-compat"

RESTRICT="nostrip"

src_install() {
	cd "${WORKDIR}"
	dodir /
	cp -RPvf "${WORKDIR}"/* "${ED}"/

	cp "${FILESDIR}"/75emul-linux-x86-base "${T}"/75emul-linux-x86-base
	eprefixify "${T}"/75emul-linux-x86-base

	doenvd "${T}"/75emul-linux-x86-base
}
