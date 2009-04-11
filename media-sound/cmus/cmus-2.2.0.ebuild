# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/cmus/cmus-2.2.0.ebuild,v 1.9 2008/10/25 22:18:35 pvdabeel Exp $

inherit eutils multilib

DESCRIPTION="A ncurses based music player with plugin support for many formats"
HOMEPAGE="http://cmus.sourceforge.net/"
SRC_URI="http://mirror.greaterscope.net/cmus/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="aac alsa ao arts debug examples flac mad mikmod modplug mp3 mp4 musepack \
	oss pidgin vorbis wavpack wma zsh-completion"

DEPEND="sys-libs/ncurses
	aac? ( media-libs/faad2 )
	alsa? ( >=media-libs/alsa-lib-1.0.11 )
	ao? (  media-libs/libao )
	arts? ( kde-base/arts )
	flac? ( media-libs/flac )
	mad? ( >=media-libs/libmad-0.14 )
	mikmod? ( media-libs/libmikmod )
	modplug? ( >=media-libs/libmodplug-0.7 )
	mp3? ( >=media-libs/libmad-0.14 )
	mp4? ( media-libs/libmp4v2
		media-libs/faad2 )
	musepack? ( >=media-libs/libmpcdec-1.2 )
	vorbis? ( >=media-libs/libvorbis-1.0 )
	wavpack? ( media-sound/wavpack )
	wma? ( media-video/ffmpeg )"
RDEPEND="${DEPEND}
	zsh-completion? ( app-shells/zsh )
	pidgin? ( net-im/pidgin
		dev-python/dbus-python )"

my_config() {
	local value
	use ${1} && value=y || value=n
	myconf="${myconf} ${2}=${value}"
}

pkg_setup() {
	if ! built_with_use sys-libs/ncurses unicode
	then
		ewarn
		ewarn "sys-libs/ncurses compiled without the unicode USE flag."
		ewarn "Please recompile sys-libs/ncurses with USE=unicode and emerge"
		ewarn "cmus again if you experience any problems with UTF-8 or"
		ewarn "wide characters."
		ewarn
		epause
	fi
}

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"
	if $(has_version ">=media-video/ffmpeg-0.4.9_p20080326")
	then
		epatch "${FILESDIR}"/${P}-new-ffmpeg.patch
	fi
	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	local debuglevel=1 myconf="CONFIG_SUN=n"

	use debug && debuglevel=2

	my_config aac CONFIG_AAC
	my_config ao CONFIG_AO
	my_config alsa CONFIG_ALSA
	my_config arts CONFIG_ARTS
	my_config flac CONFIG_FLAC
	my_config mad CONFIG_MAD
	my_config mikmod CONFIG_MIKMOD
	my_config mp3 CONFIG_MAD
	my_config mp4 CONFIG_MP4
	my_config modplug CONFIG_MODPLUG
	my_config musepack CONFIG_MPC
	my_config oss CONFIG_OSS
	my_config vorbis CONFIG_VORBIS
	my_config wavpack CONFIG_WAVPACK
	my_config wma CONFIG_FFMPEG

	# econf doesn't work, because configure wants "prefix" (and similar) without dashes
	./configure prefix=${EPREFIX} ${myconf} DEBUG=${debuglevel} || die "configure failed"

	emake || die "emake failed"
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
