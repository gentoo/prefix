# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/cmus/cmus-2.2.0-r2.ebuild,v 1.4 2009/09/25 11:21:35 maekke Exp $

EAPI=2
inherit eutils multilib

DESCRIPTION="A ncurses based music player with plugin support for many formats"
HOMEPAGE="http://cmus.sourceforge.net/"
SRC_URI="http://mirror.greaterscope.net/cmus/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="aac alsa ao debug examples flac mad mikmod modplug mp4 musepack \
	oss pidgin unicode vorbis wavpack wma zsh-completion"

DEPEND="sys-libs/ncurses[unicode?]
	aac? ( media-libs/faad2 )
	alsa? ( >=media-libs/alsa-lib-1.0.11 )
	ao? (  media-libs/libao )
	flac? ( media-libs/flac )
	mad? ( >=media-libs/libmad-0.14 )
	mikmod? ( media-libs/libmikmod )
	modplug? ( >=media-libs/libmodplug-0.7 )
	mp4? ( >=media-libs/libmp4v2-1.9 )
	musepack? ( media-libs/libmpcdecsv7 )
	vorbis? ( >=media-libs/libvorbis-1.0 )
	wavpack? ( media-sound/wavpack )
	wma? ( >=media-video/ffmpeg-0.4.9_p20080326 )"
RDEPEND="${DEPEND}
	zsh-completion? ( app-shells/zsh )
	pidgin? ( net-im/pidgin
		dev-python/dbus-python )"

my_config() {
	local value
	use ${1} && value=y || value=n
	myconf="${myconf} ${2}=${value}"
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-new-ffmpeg.patch \
		"${FILESDIR}"/${P}-symlink_attack.patch \
		"${FILESDIR}"/${P}-libmpcdecsv7.patch
	epatch "${FILESDIR}"/${P}-interix.patch

	sed -i -e 's:<mp4.h>:<mp4v2/mp4v2.h>:' mp4.c || die "sed failed"
}

src_configure() {
	local debuglevel=1 myconf="CONFIG_SUN=n"

	use debug && debuglevel=2

	my_config aac CONFIG_AAC
	my_config ao CONFIG_AO
	my_config alsa CONFIG_ALSA
	my_config flac CONFIG_FLAC
	my_config mad CONFIG_MAD
	my_config mikmod CONFIG_MIKMOD
	my_config mp4 CONFIG_MP4
	my_config modplug CONFIG_MODPLUG
	my_config musepack CONFIG_MPC
	my_config oss CONFIG_OSS
	my_config vorbis CONFIG_VORBIS
	my_config wavpack CONFIG_WAVPACK
	my_config wma CONFIG_FFMPEG

	# econf doesn't work, because configure wants "prefix" (and similar) without dashes
	./configure prefix="${EPREFIX}"/usr ${myconf} exampledir="${EPREFIX}"/usr/share/doc/${PF}/examples \
		libdir="${EPREFIX}"/usr/$(get_libdir) DEBUG=${debuglevel} || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README
	use examples || rm -rf "${ED}/usr/share/doc/${PF}/examples/"

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/_cmus
	fi

	if use pidgin; then
		sed -i -e "s:/usr/local/bin/python:/usr/bin/python:" contrib/cmus-updatepidgin.py
		newbin contrib/cmus-updatepidgin.py cmus-updatepidgin
	fi
}
