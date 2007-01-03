# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/perl-cleaner/perl-cleaner-1.04.3.ebuild,v 1.11 2006/09/03 19:49:47 kumba Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="http://dev.gentoo.org/~mcummings/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="app-shells/bash"
RDEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}/bin
	epatch "${FILESDIR}"/${P}-prefix.patch
	ebegin "Adjusting to prefix"
	sed -i \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
		perl-cleaner
	eend $?
}

src_install() {
	dobin bin/perl-cleaner || die
	doman man/perl-cleaner.1
}
