# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/rocksndiamonds/rocksndiamonds-3.2.4.ebuild,v 1.3 2008/06/23 21:52:33 ken69267 Exp $

EAPI="prefix"

inherit flag-o-matic eutils games

DESCRIPTION="A Boulderdash clone"
HOMEPAGE="http://www.artsoft.org/rocksndiamonds/"
SRC_URI="http://www.artsoft.org/RELEASES/unix/rocksndiamonds/${P}.tar.gz
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/Contributions-1.2.0.zip
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/BD2K3-1.0.0.zip
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/Boulder_Dash_Dream-1.0.0.zip
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/rnd-contrib-1.0.0.tar.gz
	http://www.artsoft.org/RELEASES/unix/rocksndiamonds/levels/rockslevels-emc-1.0.tar.gz
	http://www.artsoft.org/RELEASES/unix/rocksndiamonds/levels/rockslevels-sp-1.0.tar.gz
	http://www.artsoft.org/RELEASES/unix/rocksndiamonds/levels/rockslevels-dx-1.0.tar.gz
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/Snake_Bite-1.0.0.zip
	http://www.artsoft.org/RELEASES/rocksndiamonds/levels/Sokoban-1.0.0.zip
	http://www.jb-line.de/rnd_jue-v7.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="X sdl"

DEPEND="app-arch/unzip
	X? ( x11-libs/libX11 )
	!sdl? ( x11-libs/libX11 )
	sdl? (
		>=media-libs/libsdl-1.2.3
		>=media-libs/sdl-mixer-1.2.4
		media-libs/sdl-net
		>=media-libs/sdl-image-1.2.2
		media-libs/smpeg
	)"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	unpack \
		rockslevels-emc-1.0.tar.gz \
		rockslevels-sp-1.0.tar.gz \
		rockslevels-dx-1.0.tar.gz

	# make it parallel-friendly.
	epatch "${FILESDIR}"/${P}-parallel-build.patch
	sed -i \
		-e 's:\$(MAKE_CMD):$(MAKE) -C $(SRC_DIR):' \
		-e '/^MAKE/d' \
		Makefile \
		|| die "sed failed"

	cd levels
	unpack \
		rnd_jue-v7.zip \
		BD2K3-1.0.0.zip \
		rnd-contrib-1.0.0.tar.gz \
		Snake_Bite-1.0.0.zip \
		Contributions-1.2.0.zip \
		Boulder_Dash_Dream-1.0.0.zip \
		Sokoban-1.0.0.zip
}

src_compile() {
	replace-cpu-flags k6 k6-1 k6-2 i586

	local makeopts="RO_GAME_DIR=${GAMES_DATADIR}/${PN} RW_GAME_DIR=${GAMES_STATEDIR}/${PN}"
	if use X || { ! use X && ! use sdl; } ; then
		make clean || die
		emake ${makeopts} OPTIONS="${CFLAGS}" x11 || die
		mv rocksndiamonds{,.x11}
	fi
	if use sdl ; then
		make clean || die
		emake ${makeopts} OPTIONS="${CFLAGS}" sdl || die
		mv rocksndiamonds{,.sdl}
	fi
}

src_install() {
	if use X || { ! use X && ! use sdl; } ; then
		dogamesbin rocksndiamonds.x11 || die "dogamesbin failed"
	fi
	if use sdl ; then
		dogamesbin rocksndiamonds.sdl || die "dogamesbin failed"
		dosym rocksndiamonds.sdl "${GAMES_BINDIR}/rocksndiamonds"
	else
		dosym rocksndiamonds.x11 "${GAMES_BINDIR}/rocksndiamonds"
	fi
	insinto "${GAMES_DATADIR#${EPREFIX}}/${PN}"
	doins -r graphics levels music sounds || die "doins failed"

	newman rocksndiamonds.{1,6}
	dodoc CHANGES CREDITS HARDWARE README TODO docs/elements/*.txt
	newicon graphics/gfx_classic/rocks_icon_32x32.pcx ${PN}.pcx
	make_desktop_entry rocksndiamonds "Rocks 'N' Diamonds" /usr/share/pixmaps/${PN}.pcx

	prepgamesdirs
}
