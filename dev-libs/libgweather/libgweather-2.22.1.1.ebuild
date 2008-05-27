# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgweather/libgweather-2.22.1.1.ebuild,v 1.3 2008/05/27 03:22:59 jer Exp $

EAPI="prefix"

inherit gnome2 autotools

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.11
	>=dev-libs/glib-2.13
	>=gnome-base/gconf-2.8
	>=gnome-base/gnome-vfs-2.15.4
	>=dev-libs/libxml2-2.6.0
	!<gnome-base/gnome-applets-2.22.0"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19"

src_unpack() {
	gnome2_src_unpack
	eautoreconf # need new libtool for interix
}

pkg_postinst() {
	gnome2_pkg_postinst

	ewarn "Please run revdep-rebuild after upgrading this package."
}
