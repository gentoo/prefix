# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libao/libao-0.8.8.ebuild,v 1.9 2009/06/01 14:31:23 ssuominen Exp $

EAPI=2
inherit eutils libtool autotools

DESCRIPTION="the audio output library"
HOMEPAGE="http://www.xiph.org/ao"
SRC_URI="http://downloads.xiph.org/releases/ao/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="alsa doc nas mmap pulseaudio"

RDEPEND="alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	esd? ( >=media-sound/esound-0.2.22 )
	nas? ( media-libs/nas )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-alsa09-buffertime-milliseconds.patch
	elibtoolize
	eautoreconf # need new libtool for interix
}

src_configure() {
	econf \
		--enable-shared \
		--disable-static \
		$(use_enable alsa alsa09) \
		$(use_enable mmap alsa09-mmap) \
		--disable-arts \
		--disable-esd \
		$(use_enable nas) \
		$(use_enable pulseaudio pulse)
	emake || die "emake failed."
}

src_install () {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	rm -rf "${ED}"/usr/share/doc/libao*
	dodoc AUTHORS CHANGES README TODO
	use doc && dohtml -A c doc/*.html
}
