# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/perl-cleaner/perl-cleaner-1.01.ebuild,v 1.3 2005/09/24 04:12:48 vapier Exp $

EAPI="prefix"

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="http://dev.gentoo.org/~mcummings/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ~ppc-macos ppc64 s390 sh sparc x86"
IUSE=""

DEPEND="app-shells/bash"

RDEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_install() {
	dodir /usr/bin
	cp ${S}/bin/perl-cleaner ${D}/usr/bin/
	dodir /usr/share/man/man1
	doman man/perl-cleaner.1
}
