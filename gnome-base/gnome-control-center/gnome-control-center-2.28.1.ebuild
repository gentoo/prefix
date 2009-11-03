# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-control-center/gnome-control-center-2.28.1.ebuild,v 1.1 2009/10/29 22:18:08 eva Exp $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="The gnome2 Desktop configuration tool"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="eds"

RDEPEND="x11-libs/libXft
	>=x11-libs/libXi-1.2
	>=x11-libs/gtk+-2.15.0
	>=dev-libs/glib-2.17.4
	>=gnome-base/gconf-2.0
	>=gnome-base/librsvg-2.0
	>=gnome-base/nautilus-2.6
	>=media-libs/fontconfig-1
	>=dev-libs/dbus-glib-0.73
	>=x11-libs/libxklavier-4.0
	>=x11-wm/metacity-2.23.1
	>=gnome-base/libgnomekbd-2.27.4
	>=gnome-base/gnome-desktop-2.27.90
	>=gnome-base/gnome-menus-2.11.1
	gnome-base/gnome-settings-daemon

	dev-libs/libunique
	x11-libs/pango
	dev-libs/libxml2
	media-libs/freetype
	>=media-libs/libcanberra-0.4[gtk]

	eds? ( >=gnome-extra/evolution-data-server-1.7.90 )

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
	>=app-text/gnome-doc-utils-0.10.1"
# Needed for autoreconf
#	gnome-base/gnome-common

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		--disable-static
		$(use_enable eds aboutme)"
}

src_prepare() {
	gnome2_src_prepare

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"

	# Fix compilation on fbsd, bug #256958
	epatch "${FILESDIR}/${PN}-2.24.0.1-fbsd.patch"
}

src_install() {
	gnome2_src_install
	# gmodule is used to load plugins
	# (on POSIX systems gmodule uses dlopen)
	find "${ED}" -name "*.la" -delete || die "remove of la files failed"
}
