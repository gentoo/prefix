# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-places/xfce4-places-1.2.0.ebuild,v 1.1 2009/08/01 01:15:27 darkside Exp $

inherit xfce4

xfce4_thunar_plugin

DESCRIPTION="Places menu plug-in for panel, like GNOME's"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"
# SRC_URI not needed in ebuild once bug 279837 is resolved
SRC_URI="http://archive.xfce.org/src/panel-plugins/${PN}-plugin/1.2/${PN}-plugin-${PV}.tar.bz2"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"
