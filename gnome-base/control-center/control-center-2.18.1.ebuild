# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/control-center/control-center-2.18.1.ebuild,v 1.3 2007/05/01 16:05:23 dang Exp $

EAPI="prefix"

inherit eutils gnome2 autotools

DESCRIPTION="The gnome2 Desktop configuration tool"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="alsa eds esd gstreamer hal"

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
	>=dev-libs/glib-2.8
	>=x11-libs/gtk+-2.10
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
	gnome-base/libgnomekbd
	esd? ( media-sound/esound )
	hal? ( >=sys-apps/hal-0.5.6 )
	dev-libs/libxml2
	>=x11-wm/metacity-2.8.6-r1
	>=x11-libs/libxklavier-2.91
	>=gnome-base/libgnome-2.2
	media-libs/freetype
	>=gnome-base/orbit-2.12.4
	||  (
		>=dev-libs/dbus-glib-0.71
		( <sys-apps/dbus-0.90 >=sys-apps/dbus-0.60 )
	)
	eds? ( >=gnome-extra/evolution-data-server-1.7 )
	!arm? ( alsa? ( >=media-libs/alsa-lib-0.9 ) )
	gstreamer?	(
		>=media-libs/gst-plugins-base-0.10.2
		>=media-libs/gstreamer-0.10.2
	)"

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

pkg_setup() {
	G2CONF="${G2CONF} --disable-schemas-install \
		--disable-update-mimedb \
		--disable-scrollkeeper  \
		--enable-vfs-methods    \
		$(use_enable esd)       \
		$(use_enable alsa)      \
		$(use_enable hal)       \
		$(use_enable eds aboutme)"

	if use gstreamer ; then
		G2CONF="${G2CONF} --enable-gstreamer=0.10"
	else
		G2CONF="${G2CONF} --enable-gstreamer=no"
	fi
}

src_unpack() {
	gnome2_src_unpack

	# Gentoo-specific support for xcursor themes. See bug #103638.
	epatch ${FILESDIR}/${PN}-2.11-gentoo_xcursor.patch

	# Disable the master pty check, as it causes sandbox violations
	epatch ${FILESDIR}/${PN}-2.13.5-disable-master-pty.patch

	# Allow building with scrollkeeper
	epatch ${FILESDIR}/${PN}-2.18.1-gnome-doc-utils-fix.patch

	# Build on fbsd.  Bug #176655
	epatch ${FILESDIR}/${PN}-2.18.1-fbsd.patch

	eautoreconf
	intltoolize --force || die
}
