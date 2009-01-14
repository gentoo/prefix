# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-datetime/xfce4-datetime-0.6.1.ebuild,v 1.3 2009/01/13 15:36:22 ranger Exp $

EAPI="prefix"

inherit xfce44

DESCRIPTION="Panel plugin displaying date, time and small calendar"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

xfce44
xfce44_goodies_panel_plugin

DOCS="AUTHORS ChangeLog NEWS README THANKS"
