# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/control-center/control-center-2.20.3.ebuild,v 1.9 2008/04/24 21:00:31 dang Exp $
EAPI="prefix 1"

inherit eutils gnome2 autotools

DESCRIPTION="The gnome2 Desktop configuration tool"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/gnome-${PN}/${PVP[0]}.${PVP[1]}/gnome-${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="alsa eds esd hal"

RDEPEND=">=gnome-base/gnome-vfs-2.2
	>=media-libs/fontconfig-1
	>=virtual/xft-2.1.2
	x11-apps/xmodmap
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXdmcp
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXxf86misc
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
	>=dev-libs/glib-2.13.0
	>=x11-libs/gtk+-2.11.6
	>=gnome-base/libbonobo-2
	>=gnome-base/libgnomeui-2.2
	>=gnome-base/nautilus-2.6
	>=gnome-base/gconf-2
	>=gnome-base/libglade-2
	>=gnome-base/libbonoboui-2.2
	>=gnome-base/gnome-desktop-2.2
	>=gnome-base/librsvg-2
	>=gnome-base/gnome-menus-2.11.1
	>=gnome-base/gnome-panel-2
	>=gnome-base/libgnomekbd-0.1
	esd? ( >=media-sound/esound-0.2.38 )
	hal? ( >=sys-apps/hal-0.5.6 )
	dev-libs/libxml2
	>=x11-wm/metacity-2.8.6-r1
	>=x11-libs/libxklavier-3.2
	>=gnome-base/libgnome-2.2
	media-libs/freetype
	>=gnome-base/orbit-2.12.4
	>=dev-libs/dbus-glib-0.71
	eds? ( >=gnome-extra/evolution-data-server-1.7.90 )
	!arm? ( alsa? ( >=media-libs/alsa-lib-0.9 ) )
	>=media-libs/gst-plugins-base-0.10.2
	media-plugins/gst-plugins-gconf
	>=media-libs/gstreamer-0.10.2
	media-plugins/gst-plugins-meta:0.10"
DEPEND="${RDEPEND}
	x11-proto/kbproto
	x11-proto/xextproto
	x11-libs/libxkbfile
	x11-proto/xf86miscproto
	x11-proto/scrnsaverproto
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	>=app-text/gnome-doc-utils-0.10.1
	app-text/scrollkeeper
	gnome-base/gnome-common
	dev-util/desktop-file-utils"

DOCS="AUTHORS ChangeLog NEWS README TODO"
S="${WORKDIR}/gnome-${P}"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		--disable-update-mimedb
		--disable-scrollkeeper
		--enable-vfs-methods
		--enable-gstreamer=0.10
		$(use_enable esd)
		$(use_enable alsa)
		$(use_enable hal)
		$(use_enable eds aboutme)"
}

src_unpack() {
	gnome2_src_unpack

	# Allow building with scrollkeeper
	epatch "${FILESDIR}/${PN}-2.18.1-gnome-doc-utils-fix.patch"

	# This patch is conditional (bug #201730)
	use esd || epatch "${FILESDIR}/${PN}-2.19.90-no-esd.patch"

	intltoolize --force || die
	eautoreconf
}
