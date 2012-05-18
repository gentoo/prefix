# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/check/check-0.9.8.ebuild,v 1.9 2011/02/26 18:28:54 armin76 Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="A unit test framework for C"
HOMEPAGE="http://sourceforge.net/projects/check/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-0.9.6-AM_PATH_CHECK.patch \
		"${FILESDIR}"/${PN}-0.9.6-64bitsafe.patch

	sed -i -e '/^docdir =/d' {.,doc}/Makefile.am || die

	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS *ChangeLog* NEWS README THANKS TODO

	rm -f "${ED}"/usr/share/doc/${PF}/COPYING*
	find "${ED}" -name '*.la' -exec rm -f {} +
}
