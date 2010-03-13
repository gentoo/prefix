# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/perl-cleaner/perl-cleaner-2.0.ebuild,v 1.1 2010/02/16 22:20:58 tove Exp $

inherit eutils prefix

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~tove/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-shells/bash"
RDEPEND="${DEPEND}
	dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2_pre090924-prefix.patch
	eprefixify perl-cleaner
}

src_install() {
	dosbin perl-cleaner || die
	doman perl-cleaner.1 || die
}
