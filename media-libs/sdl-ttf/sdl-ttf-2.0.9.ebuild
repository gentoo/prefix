# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-ttf/sdl-ttf-2.0.9.ebuild,v 1.1 2007/07/21 19:48:08 vapier Exp $

EAPI="prefix"

MY_P="${P/sdl-/SDL_}"
DESCRIPTION="library that allows you to use TrueType fonts in SDL applications"
HOMEPAGE="http://www.libsdl.org/projects/SDL_ttf/"
SRC_URI="http://www.libsdl.org/projects/SDL_ttf/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="X"

DEPEND="X? ( x11-libs/libXt )
	media-libs/libsdl
	>=media-libs/freetype-2.3"

S=${WORKDIR}/${MY_P}

src_compile() {
	econf $(use_with X x) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES README
}
