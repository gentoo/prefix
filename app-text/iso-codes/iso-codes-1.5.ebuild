# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/iso-codes/iso-codes-1.5.ebuild,v 1.9 2008/02/19 00:11:18 eva Exp $

EAPI="prefix"

WANT_AUTOMAKE="latest"
inherit eutils autotools

DESCRIPTION="Provides the list of country and language names"
HOMEPAGE="http://alioth.debian.org/projects/pkg-isocodes/"
SRC_URI="ftp://pkg-isocodes.alioth.debian.org/pub/pkg-isocodes/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="sys-devel/gettext
	>=dev-lang/python-2.3
	>=sys-devel/automake-1.9"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix install location for multilib machines
	sed -i -e 's:(datadir)/pkgconfig:(libdir)/pkgconfig:g' Makefile.am

	eautomake
}

src_compile() {
	econf || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	dodoc ChangeLog README TODO
}
