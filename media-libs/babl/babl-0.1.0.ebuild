# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.1.0.ebuild,v 1.1 2009/09/01 08:50:02 patrick Exp $

EAPI="2"

inherit eutils autotools

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="ftp://ftp.gtk.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="sse mmx"

DEPEND="virtual/libc"

src_prepare() {
	epatch "${FILESDIR}/${P}-build-fixes.patch"
	sed -i -e "1c\#!${EPREFIX}/bin/bash" docs/tools/xml_insert.sh || die
#	epatch "${FILESDIR}"/${PN}-0.0.22-darwin.patch
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable mmx) \
		$(use_enable sse)
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	find "${ED}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog README NEWS || die "dodoc failed"
}
