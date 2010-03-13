# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libpaper/libpaper-1.1.23_p2.ebuild,v 1.1 2010/03/08 07:30:09 sping Exp $

EAPI="2"

inherit eutils autotools

MY_PV=${PV/_p/+nmu}
DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="http://packages.debian.org/unstable/source/libpaper"
SRC_URI="mirror://debian/pool/main/libp/libpaper/${PN}_${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${P}-interix-getopt.patch
	eautoreconf # required for interix, was elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog debian/changelog || die "dodoc failed"
	dodir /etc
	(paperconf 2>/dev/null || echo a4) > "${ED}"/etc/papersize \
		|| die "papersize config failed"
}

pkg_postinst() {
	echo
	elog "run \"paperconf -p letter\" as root to use letter-pagesizes"
	elog "or paperconf with normal user privileges."
	echo
}
