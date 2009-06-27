# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/sox/sox-14.3.0.ebuild,v 1.1 2009/06/22 09:12:59 aballier Exp $

inherit flag-o-matic

DESCRIPTION="The swiss army knife of sound processing programs"
HOMEPAGE="http://sox.sourceforge.net"
SRC_URI="mirror://sourceforge/sox/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="alsa amrnb amrwb ao debug encode ffmpeg flac id3tag ladspa mad ogg oss png pulseaudio sndfile wavpack"

RDEPEND="alsa? ( media-libs/alsa-lib )
	encode? ( media-sound/lame )
	flac? ( media-libs/flac )
	mad? ( media-libs/libmad )
	sndfile? ( media-libs/libsndfile )
	ogg? ( media-libs/libvorbis	media-libs/libogg )
	ao? ( media-libs/libao )
	ffmpeg? ( media-video/ffmpeg )
	ladspa? ( media-libs/ladspa-sdk )
	>=media-sound/gsm-1.0.12-r1
	id3tag? ( media-libs/libid3tag )
	amrnb? ( media-libs/amrnb )
	amrwb? ( media-libs/amrwb )
	png? ( media-libs/libpng )
	pulseaudio? ( media-sound/pulseaudio )
	wavpack? ( media-sound/wavpack )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_compile () {
	# Fixes wav segfaults. See Bug #35745.
	append-flags -fsigned-char

	econf $(use_with alsa) \
		$(use_enable debug) \
		$(use_with ao) \
		$(use_with oss) \
		$(use_with encode lame) \
		$(use_with mad) \
		$(use_with sndfile) \
		$(use_with flac) \
		$(use_with ogg oggvorbis) \
		$(use_with ffmpeg) \
		$(use_with ladspa) \
		$(use_with id3tag) \
		$(use_with amrwb) \
		$(use_with amrnb) \
		$(use_with png) \
		$(use_with pulseaudio) \
		$(use_with wavpack) \
		--with-distro="Gentoo"

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc NEWS ChangeLog README AUTHORS
}
