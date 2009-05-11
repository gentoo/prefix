# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gegl/gegl-0.0.22.ebuild,v 1.10 2009/04/06 14:21:33 ranger Exp $

inherit eutils

DESCRIPTION="A graph based image processing framework"
HOMEPAGE="http://www.gegl.org/"
SRC_URI="ftp://ftp.gimp.org/pub/${PN}/0.0/${P}.tar.bz2"

LICENSE="|| ( GPL-3 LGPL-3 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

IUSE="cairo debug doc ffmpeg jpeg mmx openexr png raw sdl sse svg v4l"

DEPEND=">=media-libs/babl-0.0.20
	>=dev-libs/glib-2.18.0
	media-libs/libpng
	>=x11-libs/gtk+-2.14.0
	x11-libs/pango
	cairo? ( x11-libs/cairo )
	doc? ( app-text/asciidoc
		dev-lang/ruby
		>=dev-lang/lua-5.1.0
		app-text/enscript
		media-gfx/graphviz
		media-gfx/imagemagick )
	ffmpeg? ( >=media-video/ffmpeg-0.4.9_p20080326 )
	jpeg? ( media-libs/jpeg )
	openexr? ( media-libs/openexr )
	raw? ( >=media-libs/libopenraw-0.0.5 )
	sdl? ( media-libs/libsdl )
	svg? ( >=gnome-base/librsvg-2.14.0 )"

pkg_setup() {
	if use doc && ! built_with_use 'media-gfx/imagemagick' 'png'; then
		eerror "You must build imagemagick with png support"
		die "media-gfx/imagemagick built without png"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-locale_h.diff"
}

src_compile() {
	econf --with-gtk --with-pango --with-gdk-pixbuf \
		$(use_enable debug) \
		$(use_with cairo) \
		$(use_with cairo pangocairo) \
		$(use_with v4l libv4l) \
		$(use_enable doc docs) \
		$(use_with doc graphviz) \
		$(use_with doc lua) \
		$(use_enable doc workshop) \
		$(use_with ffmpeg libavformat) \
		$(use_with jpeg libjpeg) \
		$(use_enable mmx) \
		$(use_with openexr) \
		$(use_with png libpng) \
		$(use_with raw libopenraw) \
		$(use_with sdl) \
		$(use_with svg librsvg) \
		$(use_enable sse) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	# emake install doesn't install anything
	einstall || die "einstall failed"
	find "${ED}" -name '*.la' -delete
	dodoc ChangeLog INSTALL README NEWS || die "dodoc failed"

	# don't know why einstall omits this?!
	insinto "/usr/include/${PN}-0.0/${PN}/buffer/"
	doins "${WORKDIR}/${P}/${PN}"/buffer/*.h || die "doins buffer failed"
	insinto "/usr/include/${PN}-0.0/${PN}/module/"
	doins "${WORKDIR}/${P}/${PN}"/module/*.h || die "doins module failed"
}
