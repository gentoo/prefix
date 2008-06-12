# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/perl-cleaner/perl-cleaner-1.05.ebuild,v 1.9 2008/04/14 01:31:53 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-shells/bash"
RDEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}/bin
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify perl-cleaner
}

src_install() {
	dobin bin/perl-cleaner || die
	doman man/perl-cleaner.1
}
