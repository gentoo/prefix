# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/herrie/herrie-2.0.2.ebuild,v 1.4 2008/06/16 19:25:25 bluebird Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Herrie is a command line music player."
HOMEPAGE="http://herrie.info/"
SRC_URI="http://herrie.info/distfiles/${P}.tar.bz2"

LICENSE="BSD-2 GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="ao alsa pulseaudio oss http modplug mp3 sndfile vorbis xspf unicode nls coreaudio"

# Supported languages
APP_LINGUAS="ca da de es fi ga nl pl pt_BR ru sv tr vi zh_CN"
for X in ${APP_LINGUAS}; do
	IUSE="${IUSE} linguas_${X}"
done

DEPEND="sys-libs/ncurses
	>=dev-libs/glib-2.0
	ao? ( media-libs/libao )
	alsa? ( media-libs/alsa-lib )
	http? ( net-misc/curl )
	modplug? ( media-libs/libmodplug )
	mp3? ( media-libs/libmad
		media-libs/libid3tag )
	pulseaudio? ( media-sound/pulseaudio )
	sndfile? ( media-libs/libsndfile )
	vorbis? ( media-libs/libvorbis )
	xspf? ( >=media-libs/libspiff-0.6.5 )
	!ao? ( !alsa? ( !pulseaudio? ( !oss? ( !coreaudio? ( media-libs/alsa-lib ) ) ) ) )
	"
RDEPEND="${DEPEND}"
DEPEND="nls? ( sys-devel/gettext )
	dev-util/pkgconfig"

pkg_setup() {
	if use unicode && ! built_with_use sys-libs/ncurses unicode; then
		echo
		eerror "Rebuild sys-libs/ncurses with USE=unicode if you need unicode in herrie."
		die "Rebuild sys-libs/ncurses with USE=unicode if you need unicode in herrie."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.8-chost.patch"
}

src_compile() {
	if ! use ao && ! use alsa && ! use pulseaudio && ! use oss && ! use coreaudio ; then
		ewarn "No audio output selected (ao, alsa, pulseaudio, oss), defaulting to alsa."
	fi

	# We could add coreaudio here if on osx
	local EXTRA_CONF="verbose no_strip"
	use ao && EXTRA_CONF="${EXTRA_CONF} ao"
	use alsa && EXTRA_CONF="${EXTRA_CONF} alsa"
	use coreaudio && EXTRA_CONF="${EXTRA_CONF} coreaudio"
	use http || EXTRA_CONF="${EXTRA_CONF} no_http no_scrobbler"
	use mp3 || EXTRA_CONF="${EXTRA_CONF} no_mp3"
	use modplug || EXTRA_CONF="${EXTRA_CONF} no_modplug"
	use nls || EXTRA_CONF="${EXTRA_CONF} no_nls"
	use oss && EXTRA_CONF="${EXTRA_CONF} oss"
	use pulseaudio && EXTRA_CONF="${EXTRA_CONF} pulse"
	use sndfile || EXTRA_CONF="${EXTRA_CONF} no_sndfile"
	use unicode || EXTRA_CONF="${EXTRA_CONF} ncurses"
	use vorbis || EXTRA_CONF="${EXTRA_CONF} no_vorbis"
	use xspf || EXTRA_CONF="${EXTRA_CONF} no_xspf"

	einfo "./configure ${EXTRA_CONF}"
	CC="$(tc-getCC)" PREFIX="${EPREFIX}"/usr MANDIR="${EPREFIX}"/usr/share/man \
		./configure ${EXTRA_CONF} || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README ChangeLog
}
