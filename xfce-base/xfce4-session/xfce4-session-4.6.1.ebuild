# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-session/xfce4-session-4.6.1.ebuild,v 1.11 2009/08/02 08:18:38 ssuominen Exp $

EAPI=2
inherit flag-o-matic xfconf

DESCRIPTION="Session manager for Xfce4"
HOMEPAGE="http://www.xfce.org/projects/xfce4-session/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug gnome gnome-keyring profile"

RDEPEND="gnome-base/libglade
	>=dev-libs/dbus-glib-0.73
	x11-libs/libX11
	x11-libs/libSM
	>=x11-libs/libwnck-2.12
	x11-apps/iceauth
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-base/xfconf-4.6
	>=xfce-base/xfce-utils-4.6
	games-misc/fortune-mod
	gnome? ( gnome-base/gconf )
	gnome-keyring? ( gnome-base/gnome-keyring )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable gnome)
		$(use_enable gnome-keyring libgnome-keyring)
		$(use_enable debug)
		$(use_enable profile profiling)
		$(use_enable profile gcov)"
	DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"
}

src_configure() {
	use profile && filter-flags -fomit-frame-pointer
	xfconf_src_configure
}
