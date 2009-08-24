# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-settings/xfce4-settings-4.6.1.ebuild,v 1.13 2009/08/23 17:45:19 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Settings daemon for Xfce4"
HOMEPAGE="http://www.xfce.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug +keyboard libnotify sound"

RDEPEND=">=dev-libs/glib-2.12:2
	dev-libs/dbus-glib
	gnome-base/libglade
	>=x11-libs/gtk+-2.10:2
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libwnck
	!prefix? ( >=x11-base/xorg-server-1.5.3 )
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-base/xfconf-4.6
	>=xfce-base/exo-0.3.100
	libnotify? ( x11-libs/libnotify )
	keyboard? ( <x11-libs/libxklavier-4 )
	sound? ( media-libs/libcanberra )"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig
	x11-proto/inputproto
	x11-proto/xf86vidmodeproto
	!xfce-base/xfce-mcs-manager
	!xfce-base/xfce-mcs-plugins"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable libnotify)
		--enable-xcursor
		$(use_enable keyboard libxklavier)
		$(use_enable sound sound-settings)
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS TODO"
}
