# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.3.ebuild,v 1.14 2007/10/22 04:55:33 jer Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
	epunt_cxx
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
