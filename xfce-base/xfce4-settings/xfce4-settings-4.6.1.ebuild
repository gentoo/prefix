# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-settings/xfce4-settings-4.6.1.ebuild,v 1.1 2009/04/21 04:26:48 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_core

DESCRIPTION="Xfce4 settings"
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
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	!xfce-base/xfce-mcs-manager
	!xfce-base/xfce-mcs-plugins
	>=xfce-extra/exo-0.3.100
	libnotify? ( x11-libs/libnotify )
	keyboard? ( x11-libs/libxklavier )
	sound? ( media-libs/libcanberra )"
DEPEND="${RDEPEND}
	dev-util/intltool
	x11-proto/inputproto
	x11-proto/xf86vidmodeproto"

XFCE_CONFIG+=" $(use_enable libnotify) $(use_enable keyboard libxklavier)
	$(use_enable sound sound-settings) --enable-xcursor"

DOCS="AUTHORS ChangeLog NEWS README TODO"
