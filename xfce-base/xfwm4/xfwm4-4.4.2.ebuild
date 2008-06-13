# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfwm4/xfwm4-4.4.2.ebuild,v 1.7 2007/12/17 18:37:16 jer Exp $

EAPI="prefix"

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Window manager"
HOMEPAGE="http://www.xfce.org/projects/xfwm4"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"

IUSE="debug startup-notification xcomposite"

RDEPEND="x11-libs/libX11
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXpm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXext
	xcomposite? ( x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXfixes )
	>=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	x11-libs/pango
	startup-notification? ( x11-libs/startup-notification )
	>=xfce-base/libxfce4mcs-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

XFCE_CONFIG="${XFCE_CONFIG} --enable-xsync --enable-render --enable-randr \
	$(use_enable xcomposite compositor)"

DOCS="AUTHORS ChangeLog COMPOSITOR NEWS README TODO"

xfce44_core_package
