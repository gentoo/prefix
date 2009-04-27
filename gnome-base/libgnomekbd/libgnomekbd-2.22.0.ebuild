# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomekbd/libgnomekbd-2.22.0.ebuild,v 1.9 2009/04/26 22:36:49 eva Exp $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="Gnome keyboard configuration library"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6
	>=sys-apps/dbus-0.92
	>=dev-libs/dbus-glib-0.34
	>=gnome-base/gconf-2.14
	>=x11-libs/gtk+-2.10.3
	>=gnome-base/libglade-2.6
	>=gnome-base/libgnome-2.16
	>=gnome-base/libgnomeui-2.16
	>=x11-libs/libxklavier-3.2
	!<gnome-base/gnome-control-center-2.17.0"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19"

DOCS="AUTHORS ChangeLog NEWS README"

# This collides with
# /etc/gconf/schemas/desktop_gnome_peripherals_keyboard_xkb.schemas from
# <=control-center-2.17...

pkg_setup() {
	# Only user interaction required graphical tests at the time of 2.22.0 - not useful for us
	G2CONF="${G2CONF} --disable-tests"
}

src_prepare() {
	# Fix linking to system's library, bug #265428
	epatch "${FILESDIR}/${P}-system-relink.patch"

	eautomake
}

src_compile() {
	# FreeBSD doesn't like -j
	use x86-fbsd && MAKEOPTS="${MAKEOPTS} -j1"
	gnome2_src_compile
}
