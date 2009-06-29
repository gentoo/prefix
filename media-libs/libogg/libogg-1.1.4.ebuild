# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.4.ebuild,v 1.1 2009/06/25 08:56:04 aballier Exp $

inherit eutils autotools

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i s/-mv8// configure.in || die "sed failed"
	eautoreconf # need new libtool for interix
	epunt_cxx
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES AUTHORS

	find "${ED}" -name '*.la' -delete
}
