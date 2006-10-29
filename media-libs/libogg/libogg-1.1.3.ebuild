# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.3.ebuild,v 1.5 2006/10/04 17:42:48 grobian Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize
	epunt_cxx
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
