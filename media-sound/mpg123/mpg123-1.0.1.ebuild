# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.0.1.ebuild,v 1.1 2007/12/30 14:32:53 drac Exp $

EAPI="prefix"

WANT_AUTOMAKE=1.9

inherit autotools eutils

DESCRIPTION="Real Time mp3 player"
HOMEPAGE="http://www.mpg123.de"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="3dnow 3dnowext alsa altivec esd jack mmx nas oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl )
	esd? ( media-sound/esound )
	nas? ( media-libs/nas )
	jack? ( media-sound/jack-audio-connection-kit )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PROVIDE="virtual/mpg123"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-no-faltivec.patch
	eautoreconf
}

src_compile() {
	local myaudio

	use alsa && myaudio="${myaudio} alsa"
	use esd && myaudio="${myaudio} esd"
	use jack && myaudio="${myaudio} jack"
	use nas && myaudio="${myaudio} nas"
	use oss && myaudio="${myaudio} oss"
	use pulseaudio && myaudio="${myaudio} pulse"
	use sdl && myaudio="${myaudio} sdl"
	[[ ${CHOST} == *apple-darwin* ]] && myaudio="${myaudio} coreaudio"

	local mycpu

	if use altivec; then
		mycpu="--with-cpu=altivec"
	elif use 3dnowext; then
		mycpu="--with-cpu=3dnowext"
	elif use 3dnow; then
		mycpu="--with-cpu=3dnow"
	elif use sse; then
		mycpu="--with-cpu=sse"
	elif use mmx; then
		mycpu="--with-cpu=mmx"
	fi
	# ASM on OSX/Intel is broken, bug #203708
	[[ ${CHOST} == *86*-apple-darwin* ]] && mycpu="--with-cpu=generic"

	econf --with-optimization=0 \
		--with-audio="${myaudio}" \
		${mycpu} || die "econf failed."

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
