# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pngtoico/pngtoico-1.0.1.ebuild,v 1.1 2006/12/09 19:55:08 graaff Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Convert png images to MS ico format"
HOMEPAGE="http://www.kernel.org/pub/software/graphics/pngtoico/"
SRC_URI="mirror://kernel/software/graphics/pngtoico/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="media-libs/libpng"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-Makefile.patch
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	dobin pngtoico
	doman pngtoico.1
}
