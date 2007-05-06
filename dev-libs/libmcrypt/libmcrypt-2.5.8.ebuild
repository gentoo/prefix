# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmcrypt/libmcrypt-2.5.8.ebuild,v 1.1 2007/05/01 06:40:44 robbat2 Exp $

EAPI="prefix"

inherit eutils libtool

RESTRICT="confcache"
DESCRIPTION="libmcrypt is a library that provides uniform interface to access several encryption algorithms."
HOMEPAGE="http://mcrypt.sourceforge.net/"
SRC_URI="mirror://sourceforge/mcrypt/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	##EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-2.5.7-m4.patch
	cd "${S}"
	elibtoolize
}

src_install() {
	dodir /usr/{bin,include,lib}
	make install DESTDIR="${D}" || die "install failure"

	dodoc AUTHORS KNOWN-BUGS INSTALL NEWS README THANKS TODO ChangeLog
	dodoc doc/README.* doc/example.c
	prepalldocs
}
