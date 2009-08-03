# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-panel/xfce4-panel-4.6.1.ebuild,v 1.11 2009/08/01 22:54:01 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Panel for Xfce4"
HOMEPAGE="http://www.xfce.org/projects/xfce4-panel/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug startup-notification"

RDEPEND=">=dev-libs/glib-2.8:2
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libSM
	>=x11-libs/gtk+-2.10:2
	>=x11-libs/libwnck-2.12
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-extra/exo-0.3.100
	startup-notification? ( x11-libs/startup-notification )"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable startup-notification)
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
}
