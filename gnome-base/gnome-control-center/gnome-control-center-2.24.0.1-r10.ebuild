# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-control-center/gnome-control-center-2.24.0.1-r10.ebuild,v 1.1 2009/07/27 00:03:27 eva Exp $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="The gnome2 Desktop configuration tool"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="eds hal +sound"

# FIXME: eel is still needed for libslab
RDEPEND="x11-libs/libXft
	>=x11-libs/gtk+-2.11.6
	>=dev-libs/glib-2.17.4
	>=gnome-base/gconf-2.0
	>=gnome-base/libglade-2
	>=gnome-base/librsvg-2.0
	>=gnome-base/nautilus-2.6
	>=media-libs/fontconfig-1
	>=dev-libs/dbus-glib-0.73
	>=x11-libs/libxklavier-3.6
	>=x11-wm/metacity-2.23.1
	>=gnome-base/gnome-panel-2.0
	>=gnome-base/libgnomekbd-2.21.4.1
	>=gnome-base/gnome-desktop-2.23.90
	>=gnome-base/gnome-menus-2.11.1
	gnome-base/eel
	gnome-base/gnome-settings-daemon

	>=media-libs/gstreamer-0.10.1.2
	>=media-libs/gst-plugins-base-0.10.1.2
	>=media-plugins/gst-plugins-gconf-0.10
	media-plugins/gst-plugins-meta:0.10

	x11-libs/pango
	dev-libs/libxml2
	media-libs/freetype

	eds? ( >=gnome-extra/evolution-data-server-1.7.90 )
	hal? ( >=sys-apps/hal-0.5.6 )
	sound? (
		>=media-libs/libcanberra-0.4[gtk]
		x11-themes/sound-theme-freedesktop )

	>=gnome-base/libbonobo-2
	>=gnome-base/libgnome-2.2
	>=gnome-base/libbonoboui-2
	>=gnome-base/libgnomeui-2.2

	x11-apps/xmodmap
	x11-libs/libXScrnSaver
	x11-libs/libXext
	x11-libs/libX11
	x11-libs/libXxf86misc
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXcursor"
DEPEND="${RDEPEND}
	x11-proto/scrnsaverproto
	x11-proto/xextproto
	x11-proto/xproto
	x11-proto/xf86miscproto
	x11-proto/kbproto
	x11-proto/randrproto
	x11-proto/renderproto

	sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19
	dev-util/desktop-file-utils

	app-text/scrollkeeper
	gnome-base/gnome-common
	>=app-text/gnome-doc-utils-0.10.1"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		--enable-gstreamer=0.10
		$(use_enable eds aboutme)
		$(use_enable hal)
		$(use_with sound libcanberra)"
}

src_prepare() {
	gnome2_src_prepare

	# Fix compilation on fbsd, bug #256958
	epatch "${FILESDIR}/${P}-fbsd.patch"

	# Upstream patch for Hor and Vert Maximise, bug #263166
	epatch "${FILESDIR}/${P}-hv-max.patch"

	# Upstream patch for fixing capplet help buttons, bug #263168
	epatch "${FILESDIR}/${P}-capplet-help.patch"

	# Add missing libgnomeui check, bug #269383
	epatch "${FILESDIR}/${P}-libgnomeui.patch"

	# Add fixes for gnome-desktop-2.26 API changes, bug #269383
	epatch "${FILESDIR}/${P}-gnome-desktop-api.patch"

	# Fix build with libxklavier-4
	epatch "${FILESDIR}/${PN}-2.26.0-libxklavier4.patch"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}
