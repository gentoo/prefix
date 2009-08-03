# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfwm4/xfwm4-4.6.1.ebuild,v 1.10 2009/08/01 22:44:27 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Window manager for Xfce4"
HOMEPAGE="http://www.xfce.org/projects/xfwm4/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug startup-notification xcomposite"

RDEPEND=">=dev-libs/glib-2.10:2
	>=x11-libs/gtk+-2.10:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXpm
	x11-libs/pango
	>=x11-libs/libwnck-2.12
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-base/xfconf-4.6
	startup-notification? ( x11-libs/startup-notification )
	xcomposite? ( x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXfixes )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable startup-notification)
		--enable-xsync
		--enable-render
		--enable-randr
		$(use_enable xcomposite compositor)
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog COMPOSITOR NEWS README TODO"
}
