# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.10.1_pre.ebuild,v 1.1 2010/02/13 17:51:22 ssuominen Exp $

# Only for testing http://bugs.gentoo.org/show_bug.cgi?id=299490

EAPI=2

MY_P=${P/_pre/-prerelease}

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://www.mpg123.org/"
SRC_URI="http://www.mpg123.org/download/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="3dnow 3dnowext alsa altivec ipv6 jack mmx nas +network oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )
	nas? ( media-libs/nas )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	sdl? ( media-libs/libsdl )
	sys-devel/libtool"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_configure() {
	local _audio=dummy
	local _output=dummy
	local _cpu=generic_fpu
	local _ipv6=disable

	for flag in nas portaudio sdl oss jack alsa pulseaudio; do
		if use ${flag}; then
			_audio="${_audio} ${flag/pulseaudio/pulse}"
			_output=${flag/pulseaudio/pulse}
		fi
	done
	use elibc_Darwin && _audio="${_audio} coreaudio"

	use altivec && _cpu=altivec

	if [[ ${ABI} = amd64 ]] && use sse; then
		_cpu=x86-64
	fi

	if [[ ${ABI} = x86 ]]; then
		_cpu=i586
		use mmx && _cpu=mmx
		use 3dnow && _cpu=3dnow
		use sse && _cpu=x86
		use 3dnowext && _cpu=x86
	fi

	if use network && use ipv6; then
		_ipv6=enable
	fi

	econf \
		--disable-dependency-tracking \
		--with-optimization=0 \
		--with-audio="${_audio}" \
		--with-default-audio=${_output} \
		--with-cpu=${_cpu} \
		$(use_enable network) \
		--${_ipv6}-ipv6
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS* README
}
