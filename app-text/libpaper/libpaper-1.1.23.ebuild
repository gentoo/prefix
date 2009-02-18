# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libpaper/libpaper-1.1.23.ebuild,v 1.9 2008/10/27 05:54:16 vapier Exp $

EAPI="prefix"

inherit eutils libtool

MY_P=${P/-/_}
DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="http://packages.debian.org/unstable/source/libpaper"
SRC_URI="mirror://debian/pool/main/libp/libpaper/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/libpaper-1.1.14.8-malloc.patch
	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog debian/changelog debian/NEWS
	dodir /etc
	(paperconf 2>/dev/null || echo a4) > "${ED}"/etc/papersize
}

pkg_postinst() {
	echo
	elog "run \"paperconfig -p letter\" as root to use letter-pagesizes"
	elog "or paperconf with normal user privileges."
	echo
}
