# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-arch/unp/unp-1.0.10.ebuild,v 1.4 2006/09/22 18:46:58 blubb Exp $

EAPI="prefix"

DESCRIPTION="Script for unpacking various file formats"
HOMEPAGE="http://packages.qa.debian.org/u/unp.html"
SRC_URI="mirror://debian/pool/main/u/unp/${PN}_${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
DEPEND="dev-lang/perl"

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dobin unp
}
