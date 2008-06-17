# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/streamripper/streamripper-1.63.5.ebuild,v 1.1 2008/06/16 16:06:18 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Extracts and records individual MP3 file tracks from shoutcast streams"
HOMEPAGE="http://streamripper.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="vorbis"

DEPEND="media-libs/libmad
	media-libs/faad2
	vorbis? ( media-libs/libvorbis )
	>=dev-libs/tre-0.7.2"

src_compile() {
	econf --disable-dependency-tracking $(use_with vorbis ogg) \
		--without-included-libmad --without-included-tre
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc CHANGES README THANKS
}
