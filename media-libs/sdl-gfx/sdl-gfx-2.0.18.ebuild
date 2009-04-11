# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-gfx/sdl-gfx-2.0.18.ebuild,v 1.1 2008/12/21 23:27:47 mr_bones_ Exp $

inherit autotools eutils flag-o-matic libtool

MY_P="${P/sdl-/SDL_}"
DESCRIPTION="Graphics drawing primitives library for SDL"
HOMEPAGE="http://www.ferzkopp.net/joomla/content/view/19/14/"
SRC_URI="http://www.ferzkopp.net/Software/SDL_gfx-2.0/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="mmx"

DEPEND="media-libs/libsdl"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's/-O//' configure.in || die "sed failed"
	epatch "${FILESDIR}"/${P}-gcc43.patch #219621
	rm -f acinclude.m4 #210137
	eautoreconf
	elibtoolize
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_enable mmx) || die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
	dohtml -r Docs/*
}

pkg_postinst() {
	ewarn "If you upgraded from sdl-gfx-2.0.13-r1 or earlier, please run"
	ewarn "\"revdep-rebuild\" from app-portage/gentoolkit"
}
