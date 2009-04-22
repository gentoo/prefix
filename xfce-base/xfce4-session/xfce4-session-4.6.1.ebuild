# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-session/xfce4-session-4.6.1.ebuild,v 1.1 2009/04/21 04:26:16 darkside Exp $

inherit xfce4

xfce4_core

DESCRIPTION="Session manager"
HOMEPAGE="http://www.xfce.org/projects/xfce4-session/"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug gnome"

RDEPEND="gnome-base/libglade
	dev-libs/dbus-glib
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libSM
	x11-libs/libwnck
	x11-apps/iceauth
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	>=xfce-base/xfce-utils-${XFCE_VERSION}
	games-misc/fortune-mod
	gnome? ( gnome-base/gconf
		gnome-base/gnome-keyring )"
DEPEND="${RDEPEND}
	dev-util/intltool"

XFCE_CONFIG+=" $(use_enable gnome)"

DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"
