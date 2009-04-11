# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.7.2.ebuild,v 1.7 2009/04/10 13:23:09 armin76 Exp $

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3."
HOMEPAGE="http://www.mpg123.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="3dnow 3dnowext alsa altivec arts esd ipv6 jack mmx nas network oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	esd? ( media-sound/esound )
	jack? ( media-sound/jack-audio-connection-kit )
	nas? ( media-libs/nas )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	sdl? ( media-libs/libsdl )
	arts? ( kde-base/arts )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	sed -i -e 's:-faltivec::' "${S}"/configure || die "sed failed."
}

src_compile() {
	local myaudio

	use alsa && myaudio="${myaudio} alsa"
	use esd && myaudio="${myaudio} esd"
	use jack && myaudio="${myaudio} jack"
	use nas && myaudio="${myaudio} nas"
	use oss && myaudio="${myaudio} oss"
	use portaudio && myaudio="${myaudio} portaudio"
	use pulseaudio && myaudio="${myaudio} pulse"
	use sdl && myaudio="${myaudio} sdl"
	use arts && myaudio="${myaudio} arts"
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

	econf --disable-dependency-tracking \
		--with-optimization=0 ${mycpu} \
		--with-audio="${myaudio}" \
		$(use_enable network) \
		$(use_enable ipv6)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS* README
}
