# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/realpath/realpath-1.12.ebuild,v 1.2 2008/05/16 14:35:18 drac Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Return the canonicalized absolute pathname"
HOMEPAGE="http://packages.debian.org/unstable/utils/realpath"
SRC_URI="mirror://debian/pool/main/r/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="!sys-freebsd/freebsd-bin"

src_compile() {
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} ${PN}.c -DVERSION=\"$PV\" -o ${PN} || die "compile failed."
}

src_install() {
	dobin ${PN} || die "dobin failed."
	doman man/${PN}.1
	newdoc debian/changelog ChangeLog.debian
}
