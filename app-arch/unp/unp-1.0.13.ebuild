# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unp/unp-1.0.13.ebuild,v 1.1 2007/12/23 17:24:03 hanno Exp $

EAPI="prefix"

DESCRIPTION="Script for unpacking various file formats"
HOMEPAGE="http://packages.qa.debian.org/u/unp.html"
SRC_URI="mirror://debian/pool/main/u/unp/${PN}_${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""
DEPEND="dev-lang/perl
	dev-perl/String-ShellQuote"

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dobin unp
}
