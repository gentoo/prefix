# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-xkb/xfce4-xkb-0.5.1.ebuild,v 1.8 2008/11/20 16:48:57 ranger Exp $

EAPI="prefix"

inherit xfce44

xfce44
xfce44_gzipped

DESCRIPTION="XKB layout switching panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
RDEPEND=">=x11-libs/libxklavier-3.2
	x11-libs/libwnck"
DEPEND="${RDEPEND}
	dev-util/intltool
	x11-proto/kbproto"

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
