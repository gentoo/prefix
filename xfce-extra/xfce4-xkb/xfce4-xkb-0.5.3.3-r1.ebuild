# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-xkb/xfce4-xkb-0.5.3.3-r1.ebuild,v 1.1 2009/07/20 16:28:03 ssuominen Exp $

inherit eutils xfce4

XFCE_VERSION=4.6
xfce4_gzipped

DESCRIPTION="XKB layout switching panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
RDEPEND=">=x11-libs/libxklavier-4
	x11-libs/libwnck"
DEPEND="${RDEPEND}
	dev-util/intltool
	x11-proto/kbproto
	gnome-base/librsvg"

DOCS="AUTHORS ChangeLog NEWS README"

xfce4_panel_plugin

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-libxklavier.patch
}
