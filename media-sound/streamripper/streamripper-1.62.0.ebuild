# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/streamripper/streamripper-1.62.0.ebuild,v 1.4 2007/06/12 15:13:09 gustavoz Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Extracts and records individual MP3 file tracks from shoutcast streams"
HOMEPAGE="http://streamripper.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="vorbis"

DEPEND="media-libs/libmad
	vorbis? ( media-libs/libogg
	media-libs/libvorbis )
	>=dev-libs/tre-0.7.2"

src_compile() {
	econf $(use_with vorbis ogg) \
		--without-included-libmad \
		--without-included-tre || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES README THANKS readme_xfade.txt
}
