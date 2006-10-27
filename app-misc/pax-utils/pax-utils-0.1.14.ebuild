# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.1.14.ebuild,v 1.2 2006/10/17 07:03:58 uberlord Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="Various ELF related utils for ELF32, ELF64 binaries useful tools that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/pax-utils-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps"

DEPEND="caps? ( sys-libs/libcap )"

src_compile() {
	emake CC=$(tc-getCC) USE_CAP=$(use caps && echo yes) || die
}

src_install() {
	make DESTDIR="${D}${EPREFIX}" install || die
}
