# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/cmus/cmus-2.3.3.ebuild,v 1.1 2010/07/18 17:13:46 fauli Exp $

EAPI=2
inherit multilib

MY_P=${PN}-v${PV}

DESCRIPTION="A ncurses based music player with plugin support for many formats"
HOMEPAGE="http://cmus.sourceforge.net/"
SRC_URI="mirror://sourceforge/cmus/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="aac alsa ao debug examples flac mad mikmod modplug mp4 musepack oss
pidgin pulseaudio unicode vorbis wavpack wma zsh-completion"

DEPEND="sys-libs/ncurses[unicode?]
	aac? ( media-libs/faad2 )
	alsa? ( >=media-libs/alsa-lib-1.0.11 )
	ao? (  media-libs/libao )
	flac? ( media-libs/flac )
	mad? ( >=media-libs/libmad-0.14 )
	mikmod? ( media-libs/libmikmod )
	modplug? ( >=media-libs/libmodplug-0.7 )
	mp4? ( >=media-libs/libmp4v2-1.9 )
	musepack? ( >=media-sound/musepack-tools-444 )
	pulseaudio? ( media-sound/pulseaudio )
	vorbis? ( >=media-libs/libvorbis-1.0 )
	wavpack? ( media-sound/wavpack )
	wma? ( >=media-video/ffmpeg-0.4.9_p20080326 )"
RDEPEND="${DEPEND}
	zsh-completion? ( app-shells/zsh )
	pidgin? ( net-im/pidgin
		dev-python/dbus-python )"

S=${WORKDIR}/${MY_P}

my_config() {
	local value
	use ${1} && value=y || value=n
	myconf="${myconf} ${2}=${value}"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.2.0-interix.patch
}

src_configure() {
	local debuglevel=1 myconf="CONFIG_ARTS=n CONFIG_SUN=n"

	use debug && debuglevel=2

	my_config flac CONFIG_FLAC
	my_config mad CONFIG_MAD
	my_config modplug CONFIG_MODPLUG
	my_config mikmod CONFIG_MIKMOD
	my_config musepack CONFIG_MPC
	my_config vorbis CONFIG_VORBIS
	my_config wavpack CONFIG_WAVPACK
	my_config mp4 CONFIG_MP4
	my_config aac CONFIG_AAC
	my_config wma CONFIG_FFMPEG
	my_config pulseaudio CONFIG_PULSE
	my_config alsa CONFIG_ALSA
	my_config ao CONFIG_AO
	my_config oss CONFIG_OSS

	./configure prefix="${EPREFIX}"/usr ${myconf} exampledir="${EPREFIX}"/usr/share/doc/${PF}/examples \
		libdir="${EPREFIX}"/usr/$(get_libdir) DEBUG=${debuglevel} || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS README TODO

	use examples || rm -rf "${ED}"/usr/share/doc/${PF}/examples

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/_cmus || die
	fi

	if use pidgin; then
		newbin contrib/cmus-updatepidgin.py cmus-updatepidgin || die
	fi
}
