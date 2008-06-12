# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-board/xmahjongg/xmahjongg-3.7.ebuild,v 1.5 2008/01/14 19:26:44 grobian Exp $

EAPI="prefix"

inherit games

DESCRIPTION="friendly GUI version of xmahjongg"
HOMEPAGE="http://www.lcdf.org/xmahjongg/"
SRC_URI="http://www.lcdf.org/xmahjongg/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="x11-libs/libSM
	x11-libs/libX11
	media-libs/libpng
	sys-libs/zlib"
DEPEND="${RDEPEND}
	x11-libs/libXt"

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	prepgamesdirs
}
