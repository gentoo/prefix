# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomekbd/libgnomekbd-2.18.1.ebuild,v 1.2 2007/04/30 17:15:18 uberlord Exp $

EAPI="prefix"

inherit eutils gnome2

DESCRIPTION="Gnome keyboard configuration library"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE=""

RDEPEND="dev-libs/dbus-glib
	>=sys-apps/dbus-0.92
	>=gnome-base/gconf-2.14
	>=x11-libs/gtk+-2.10.3
	>=gnome-base/libglade-2.6
	>=gnome-base/libgnome-2.16
	>=gnome-base/libgnomeui-2.16
	>=x11-libs/libxklavier-3
	!<gnome-base/control-center-2.17.0"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.59
	=sys-devel/automake-1.8*
	dev-util/intltool
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog INSTALL NEWS README"

# This collides with
# /etc/gconf/schemas/desktop_gnome_peripherals_keyboard_xkb.schemas from
# control-center...

src_compile() {
	# FreeBSD doesn't like -j
	MAKEOPTS="${MAKEOPTS} -j1"

	gnome2_src_compile
}
