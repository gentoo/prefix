# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/realpath/realpath-1.14.ebuild,v 1.1 2009/04/30 13:17:59 ssuominen Exp $

EAPI=2
inherit eutils toolchain-funcs

DESCRIPTION="Return the canonicalized absolute pathname"
HOMEPAGE="http://packages.debian.org/unstable/utils/realpath"
SRC_URI="mirror://debian/pool/main/r/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!sys-freebsd/freebsd-bin"
DEPEND="${RDEPEND}
	app-arch/dpkg
	app-text/po4a"

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch
}

src_compile() {
	tc-export CC
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	newdoc debian/changelog ChangeLog.debian
}
