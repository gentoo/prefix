# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-mixer/sdl-mixer-1.2.11.ebuild,v 1.1 2009/11/15 20:09:30 vapier Exp $

EAPI=2

inherit eutils

MY_P=${P/sdl-/SDL_}
DESCRIPTION="Simple Direct Media Layer Mixer Library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_mixer/"
SRC_URI="http://www.libsdl.org/projects/SDL_mixer/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="flac mad +midi mikmod mp3 timidity vorbis +wav"

DEPEND=">=media-libs/libsdl-1.2.10
	flac? ( media-libs/flac )
	timidity? ( media-sound/timidity++ )
	mad? ( media-libs/libmad )
	!mad? ( mp3? ( >=media-libs/smpeg-0.4.4-r1 ) )
	vorbis? ( >=media-libs/libvorbis-1.0_beta4 media-libs/libogg )
	mikmod? ( >=media-libs/libmikmod-3.1.10 )"

S=${WORKDIR}/${MY_P}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable wav music-wave) \
		$(use_enable midi music-midi) \
		$(use_enable timidity music-timidity-midi) \
		$(use_enable mikmod music-mod) \
		$(use_enable vorbis music-ogg) \
		$(use_enable flac music-flac) \
		$(use mad && echo --disable-music-mp3 || use_enable mp3 music-mp3) \
		$(use_enable mad music-mp3-mad-gpl) \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES README
}
