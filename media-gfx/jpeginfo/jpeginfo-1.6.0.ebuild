# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jpeginfo/jpeginfo-1.6.0.ebuild,v 1.16 2009/11/27 11:53:53 flameeyes Exp $

inherit toolchain-funcs

IUSE=""

DESCRIPTION="Prints information and tests integrity of JPEG/JFIF files."
HOMEPAGE="http://www.cc.jyu.fi/~tjko/projects.html"
SRC_URI="http://www.cc.jyu.fi/~tjko/src/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=">=media-libs/jpeg-6b"

src_compile() {
	tc-export CC
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	# bug #294820
	emake -j1 INSTALL_ROOT="${D}" install || die

	dodoc COPY* README
}
