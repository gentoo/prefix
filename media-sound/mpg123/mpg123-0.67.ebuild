# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-0.67.ebuild,v 1.9 2007/11/29 17:54:08 armin76 Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="Real Time mp3 player"
HOMEPAGE="http://www.mpg123.de"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="3dnow 3dnowext alsa altivec esd jack mmx nas oss portaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	sdl? ( !alsa? ( !oss? ( media-libs/libsdl ) ) )
	esd? ( !alsa? ( !oss? ( !sdl? ( media-sound/esound ) ) ) )
	nas? ( !alsa? ( !oss? ( !sdl? ( !esd? ( media-libs/nas ) ) ) ) )
	jack? ( !alsa? ( !oss? ( !sdl? ( !esd? ( !nas? ( media-sound/jack-audio-connection-kit ) ) ) ) ) )
	portaudio? ( !alsa? ( !oss? ( !sdl? ( !esd? ( !nas? ( !jack? ( media-libs/portaudio ) ) ) ) ) ) )"
DEPEND="${RDEPEND}"

PROVIDE="virtual/mpg123"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/${PV}-no-faltivec.patch"
	eautoreconf
}

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
	elif [[ ${CHOST} == *apple-darwin* ]] ; then
		audiodev="coreaudio";
	else audiodev="dummy"
	fi

	if use altivec; then
		myconf="--with-cpu=altivec"
	elif use 3dnowext; then
		myconf="--with-cpu=3dnowext"
	elif use 3dnow; then
		myconf="--with-cpu=3dnow"
	elif use sse; then
		myconf="--with-cpu=sse"
	elif use mmx; then
		myconf="--with-cpu=mmx"
	fi

	elog "Compiling with ${audiodev} audio output."
	elog "If that is not what you want, then select exactly ONE"
	elog "of the following USE flags:"
	elog "alsa oss sdl esd nas jack portaudio"
	elog "and recompile ${PN}."
	epause 5

	econf --with-optimization=0 \
		--with-audio=${audiodev} \
		${myconf} || die "econf failed."

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
