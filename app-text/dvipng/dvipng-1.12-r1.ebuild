# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dvipng/dvipng-1.12-r1.ebuild,v 1.1 2010/01/12 19:20:03 ulm Exp $

EAPI="2"
inherit eutils

DESCRIPTION="Translate DVI files into PNG or GIF graphics"
HOMEPAGE="http://dvipng.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="t1lib truetype test"

RDEPEND="media-libs/gd[jpeg,png]
	media-libs/libpng
	virtual/latex-base
	sys-libs/zlib
	t1lib? ( media-libs/t1lib )
	truetype? ( >=media-libs/freetype-2.1.5 )"
DEPEND="${RDEPEND}
	virtual/texi2dvi
	test? ( || ( dev-texlive/texlive-fontsrecommended app-text/ptex ) )"

src_configure() {
	if ! use t1lib; then
		# The build system autodetects libt1. We don't want that if the
		# USE flag is not set, so confuse it with a wrong name.
		sed -i -e 's/T1_InitLib/dIsAbLe&/' configure || die "sed failed"
	fi

	export VARTEXFONTS="${T}/fonts"
	econf $(use_with truetype freetype)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README RELEASE || die "dodoc failed"
}
