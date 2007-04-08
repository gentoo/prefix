# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-0.65.ebuild,v 1.2 2007/03/02 12:47:10 genstef Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Real Time mp3 player"
HOMEPAGE="http://www.mpg123.de/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="mmx 3dnow alsa oss sdl esd nas jack portaudio"

RDEPEND="alsa? ( media-libs/alsa-lib )
	sdl? ( !alsa? ( !oss? ( media-libs/libsdl ) ) )
	esd? ( !alsa? ( !oss? ( !sdl? ( media-sound/esound ) ) ) )
	nas? ( !alsa? ( !oss? ( !sdl? ( !esd? ( media-libs/nas ) ) ) ) )
	jack? ( !alsa? ( !oss? ( !sdl? ( !esd? ( !nas? ( media-sound/jack-audio-connection-kit ) ) ) ) ) )
	portaudio? ( !alsa? ( !oss? ( !sdl? ( !esd? ( !nas? ( !jack? ( media-libs/portaudio ) ) ) ) ) ) )"

DEPEND="${RDEPEND}"

PROVIDE="virtual/mpg123"

src_compile() {
	local audiodev
	if use alsa; then
		audiodev="alsa"
	elif use oss; then
		audiodev="oss"
	elif use sdl; then
		audiodev="sdl"
	elif use esd; then
		audiodev="esd"
	elif use nas; then
		audiodev="nas"
	elif use jack; then
		audiodev="jack"
	elif use portaudio; then
		audiodev="portaudio"
	elif use ppc-macos || use x86-macos; then
		audiodev="macosx";
	else audiodev="dummy"
	fi

	if use 3dnow; then
		myconf="--with-cpu=3dnow"
	elif use mmx; then
		myconf="--with-cpu=mmx"
	fi

	einfo "Compiling with ${audiodev} audio output."
	einfo "If that is not what you want, then select exactly ONE"
	einfo "of the following USE flags:"
	einfo "alsa oss sdl esd nas jack portaudio"
	einfo "and recompile ${PN}."
	epause 5
	
	econf \
	      --with-optimization=0 \
	      --with-audio=$audiodev \
	      ${myconf} || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
