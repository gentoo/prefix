# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomekbd/libgnomekbd-2.20.0-r1.ebuild,v 1.9 2008/06/05 11:55:52 remi Exp $

inherit eutils gnome2

DESCRIPTION="Gnome keyboard configuration library"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="dev-libs/dbus-glib
	>=sys-apps/dbus-0.92
	>=gnome-base/gconf-2.14
	>=x11-libs/gtk+-2.10.3
	>=gnome-base/libglade-2.6
	>=gnome-base/libgnome-2.16
	>=gnome-base/libgnomeui-2.16
	>=x11-libs/libxklavier-3
	!<gnome-base/gnome-control-center-2.17.0"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.59
	=sys-devel/automake-1.8*
	>=dev-util/intltool-0.35
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README"

# This collides with
# /etc/gconf/schemas/desktop_gnome_peripherals_keyboard_xkb.schemas from
# <=control-center-2.16...

src_unpack() {
	gnome2_src_unpack
	epatch "${FILESDIR}/${PN}-2.21.1-no-libbonobo.patch"
}

src_compile() {
	# FreeBSD doesn't like -j
	MAKEOPTS="${MAKEOPTS} -j1"

	gnome2_src_compile
}
