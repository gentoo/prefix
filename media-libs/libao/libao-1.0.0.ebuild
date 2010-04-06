# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libao/libao-1.0.0.ebuild,v 1.1 2010/04/05 15:21:16 ssuominen Exp $

EAPI=2
inherit libtool

DESCRIPTION="the audio output library"
HOMEPAGE="http://www.xiph.org/ao/"
SRC_URI="http://downloads.xiph.org/releases/ao/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="alsa nas mmap pulseaudio static-libs"

RDEPEND="alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	esd? ( >=media-sound/esound-0.2.22 )
	nas? ( media-libs/nas )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	elibtoolize
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		--disable-dependency-tracking \
		--disable-esd \
		$(use_enable alsa alsa) \
		$(use_enable mmap alsa-mmap) \
		--disable-arts \
		$(use_enable nas) \
		$(use_enable pulseaudio pulse)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS CHANGES README TODO
}
