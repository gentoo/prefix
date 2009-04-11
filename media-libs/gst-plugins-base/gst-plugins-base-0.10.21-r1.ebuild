# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.21-r1.ebuild,v 1.2 2008/12/31 03:30:28 mr_bones_ Exp $

EAPI=2

inherit autotools eutils flag-o-matic multilib versionator

PV_MAJ_MIN=$(get_version_component_range '1-2')

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="alsa cdparanoia debug gnome nls libvisual ogg pango test theora vorbis v4l X xv"

RDEPEND=">=dev-libs/glib-2.16:2
	>=media-libs/gstreamer-0.10.21-r2
	>=dev-libs/liboil-0.3.14
	X? ( x11-libs/libX11 )
	xv? ( x11-libs/libXv )
	gnome? ( gnome-base/gnome-vfs )
	pango? ( x11-libs/pango )
	alsa? ( media-libs/alsa-lib )
	cdparanoia? ( media-sound/cdparanoia )
	libvisual? ( >=media-libs/libvisual-0.4
		>=media-plugins/libvisual-plugins-0.4 )
	ogg? ( media-libs/libogg )
	theora? ( media-libs/libtheora
		media-libs/libogg )
	vorbis? ( media-libs/libvorbis
		media-libs/libogg )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	X? ( x11-proto/xproto )
	xv? ( x11-proto/videoproto
		x11-proto/xextproto
		x11-proto/xproto )
	v4l? ( virtual/os-headers )
	!media-plugins/gst-plugins-libvisual
	!media-plugins/gst-plugins-cdparanoia
	!media-plugins/gst-plugins-vorbis
	!media-plugins/gst-plugins-ogg
	!media-plugins/gst-plugins-alsa
	!media-plugins/gst-plugins-xvideo
	!media-plugins/gst-plugins-theora
	!media-plugins/gst-plugins-x
	!media-plugins/gst-plugins-pango
	!media-plugins/gst-plugins-gnomevfs
	!media-plugins/gst-plugins-gio
	!media-plugins/gst-plugins-v4l"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gtkdoc.patch
	AT_M4DIR="common/m4" eautoreconf
}

src_configure() {
	local myconf="--enable-gio --enable-experimental"

	if use xv; then
		myconf+=" --enable-x --enable-xvideo --enable-xshm"
	fi

	econf \
		--disable-static \
		--disable-dependency-tracking \
		$(use_enable nls) \
		$(use_enable debug) \
		--disable-valgrind \
		--disable-examples \
		$(use_enable test tests) \
		$(use_enable X x) \
		$(use_enable X xshm) \
		$(use_enable v4l gst_v4l) \
		$(use_enable alsa) \
		$(use_enable cdparanoia) \
		$(use_enable gnome gnome_vfs) \
		$(use_enable libvisual) \
		$(use_enable ogg) \
		$(use_enable pango) \
		$(use_enable theora) \
		$(use_enable vorbis) \
		--with-package-name="GStreamer ebuild for Gentoo" \
		--with-package-origin="http://packages.gentoo.org/package/media-libs/gst-plugins-base" \
		${myconf}
}

src_compile() {
	# GStreamer doesn't handle optimization so well
	strip-flags
	replace-flags -O3 -O2

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README RELEASE
	# Drop unnecessary libtool files
	find "${ED}"/usr/$(get_libdir) -name '*.la' -delete
}
