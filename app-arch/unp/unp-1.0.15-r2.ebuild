# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unp/unp-1.0.15-r2.ebuild,v 1.1 2009/12/23 17:39:25 hanno Exp $

EAPI=2

inherit eutils

DESCRIPTION="Script for unpacking various file formats"
HOMEPAGE="http://packages.qa.debian.org/u/unp.html"
SRC_URI="mirror://debian/pool/main/u/unp/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

src_prepare() {
	epatch "${FILESDIR}"/${P}-7z-lzma-xz.diff
}

src_install() {
	dobin ucat unp || die "dobin failed"
	doman debian/unp.1 || die "doman failed"
}
