# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/orage/orage-4.6.1.ebuild,v 1.10 2009/08/25 14:56:02 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Calendar suite for Xfce4"
HOMEPAGE="http://www.xfce.org/projects/orage/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="berkdb dbus debug libnotify"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/xfce4-panel-4.4
	berkdb? ( >=sys-libs/db-4 )
	libnotify? ( x11-libs/libnotify )
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable dbus)
		$(use_enable libnotify)
		--disable-libxfce4mcs
		$(use_enable debug)
		$(use_with berkdb bdb4)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}
