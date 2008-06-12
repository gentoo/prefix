# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/splat/splat-0.08.ebuild,v 1.20 2008/01/26 16:13:33 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Simple Portage Log Analyzer Tool"
HOMEPAGE="http://www.l8nite.net/projects/splat/"
SRC_URI="http://www.l8nite.net/projects/splat/downloads/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify splat.pl
}

src_install() {
	newbin splat.pl splat || die
	dodoc COPYING ChangeLog
}
