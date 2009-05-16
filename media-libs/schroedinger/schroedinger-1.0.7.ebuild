# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/schroedinger/schroedinger-1.0.7.ebuild,v 1.2 2009/05/15 09:14:55 aballier Exp $

inherit libtool

DESCRIPTION="C-based libraries and GStreamer plugins for the Dirac video codec"
HOMEPAGE="http://www.diracvideo.org"
SRC_URI="http://www.diracvideo.org/download/${PN}/${P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2.1 GPL-2 MIT )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="gstreamer"

RDEPEND=">=dev-libs/liboil-0.3.16
	gstreamer? ( >=media-libs/gstreamer-0.10.19
		>=media-libs/gst-plugins-base-0.10.19 )"
# Doesn't seem to build as of 1.0.5
#	opengl? ( virtual/opengl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize # dont drop, sane .so versionning on bsd
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		$(use_enable gstreamer)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS TODO
}
