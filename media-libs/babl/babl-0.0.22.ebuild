# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.0.22.ebuild,v 1.11 2009/04/06 14:14:42 ranger Exp $

inherit eutils autotools

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="ftp://ftp.gtk.org/pub/${PN}/0.0/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="sse mmx"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "1c\#!${EPREFIX}/bin/bash" docs/tools/xml_insert.sh || die
	epatch "${FILESDIR}"/${P}-darwin.patch
	eautoreconf
}

src_compile() {
	econf $(use_enable mmx) \
		$(use_enable sse) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	find "${ED}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog README NEWS || die "dodoc failed"
}
