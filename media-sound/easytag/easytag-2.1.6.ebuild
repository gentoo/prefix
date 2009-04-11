# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/easytag/easytag-2.1.6.ebuild,v 1.2 2008/07/29 19:37:56 drac Exp $

DESCRIPTION="GTK+ utility for editing MP2, MP3, MP4, FLAC, Ogg and other media tags"
HOMEPAGE="http://easytag.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="aac flac mp3 speex vorbis wavpack"

RDEPEND=">=x11-libs/gtk+-2.12
	mp3? ( >=media-libs/id3lib-3.8.3-r7
		media-libs/libid3tag )
	flac? ( media-libs/flac
		media-libs/libvorbis )
	vorbis? ( media-libs/libvorbis )
	aac? ( media-libs/libmp4v2 )
	wavpack? ( media-sound/wavpack )
	speex? ( media-libs/speex
		media-libs/libvorbis )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

src_compile() {
	econf \
		$(use_enable mp3) \
		$(use_enable mp3 id3v23) \
		$(use_enable vorbis ogg) \
		$(use_enable flac) \
		$(use_enable aac mp4) \
		$(use_enable wavpack) \
		$(use_enable speex)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README THANKS TODO USERS-GUIDE
}
