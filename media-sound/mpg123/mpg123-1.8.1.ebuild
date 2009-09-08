# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.8.1.ebuild,v 1.10 2009/09/07 12:38:40 ssuominen Exp $

EAPI=2

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3."
HOMEPAGE="http://www.mpg123.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2
	http://www.mpg123.org/download/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="3dnow 3dnowext alsa altivec ipv6 jack mmx nas +network oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )
	nas? ( media-libs/nas )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	sdl? ( media-libs/libsdl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	# Make sure there is no mpg123 symlink left
	local link="${EROOT}usr/bin/mpg123"
	local msg="Removing invalid symlink ${link}"
	if [ -L "${link}" ] && [ ! -x "${link}" ]; then
		ebegin "${msg}"
		rm -f "${link}" || die "${msg} failed, please open a bug."
		eend $?
	fi
}

src_prepare() {
	sed -i -e 's:-faltivec::' configure || die "sed failed"
}

src_configure() {
	# Audio outputs
	local myaudio=dummy
	local mydaudio=dummy

	use nas && myaudio+=" nas" mydaudio=nas
	use portaudio && myaudio+=" portaudio" mydaudio=portaudio
	use sdl && myaudio+=" sdl" mydaudio=sdl
	use oss && myaudio+=" oss" mydaudio=oss
	use jack && myaudio+=" jack" mydaudio=jack
	use alsa && myaudio+=" alsa" mydaudio=alsa
	use pulseaudio && myaudio+=" pulse" mydaudio=pulse
	use elibc_Darwin && myaudio+=" coreaudio" mydaudio=coreaudio

	# You only need to comment out the _dither part to
	# enable default settings. In case you have probs.
	local dither=_dither

	local mcpu=generic${dither}
	local int=no

	use altivec && mcpu=altivec

	if use amd64; then
		use mmx && mcpu=x86-64
		use 3dnow && mcpu=x86-64
		use sse && mcpu=x86-64${dither} int=yes
		use 3dnowext && mcpu=x86-64${dither} int=yes
	fi

	if use x86; then
		mcpu=i586${dither}

		use mmx && mcpu=mmx
		use 3dnow && mcpu=3dnow
		use sse && mcpu=sse int=yes
		use 3dnowext && mcpu=3dnowext int=yes
		use sse && use 3dnowext && mcpu=x86${dither} int=yes
	fi

	local myconf
	use network && myconf+=" $(use_enable ipv6)"

	econf \
		--disable-dependency-tracking \
		--disable-ipv6 \
		--with-optimization=0 \
		--with-audio="${myaudio}" \
		--with-default-audio=${mydaudio} \
		--with-cpu=${mcpu} \
		$(use_enable network) \
		--enable-int-quality=${int} \
		${myconf}

	einfo "Optimizing with ${mcpu} and int quality set to ${int}."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS* README
}
