# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/easytag/easytag-2.1.6-r2.ebuild,v 1.3 2009/08/15 08:44:35 maekke Exp $

EAPI=2
inherit eutils fdo-mime

DESCRIPTION="GTK+ utility for editing MP2, MP3, MP4, FLAC, Ogg and other media tags"
HOMEPAGE="http://easytag.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="flac mp3 mp4 speex vorbis wavpack"

RDEPEND=">=x11-libs/gtk+-2.12:2
	mp3? ( >=media-libs/id3lib-3.8.3-r7
		media-libs/libid3tag )
	flac? ( media-libs/flac
		media-libs/libvorbis )
	mp4? ( >=media-libs/libmp4v2-1.9.0 )
	vorbis? ( media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	speex? ( media-libs/speex
		media-libs/libvorbis )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

src_prepare() {
	epatch "${FILESDIR}"/${P}-desktop_entry.patch \
		"${FILESDIR}"/${P}-new_libmp4v2.patch
}

src_configure() {
	econf \
		$(use_enable mp3) \
		$(use_enable mp3 id3v23) \
		$(use_enable vorbis ogg) \
		$(use_enable flac) \
		$(use_enable mp4) \
		$(use_enable wavpack) \
		$(use_enable speex)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README THANKS TODO USERS-GUIDE
}

pkg_postinst() { fdo-mime_desktop_database_update; }
pkg_postrm() { fdo-mime_desktop_database_update; }
