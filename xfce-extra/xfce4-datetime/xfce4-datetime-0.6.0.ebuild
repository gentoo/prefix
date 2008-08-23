# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-datetime/xfce4-datetime-0.6.0.ebuild,v 1.1 2008/08/21 19:31:38 angelos Exp $

EAPI="prefix"

inherit xfce44

DESCRIPTION="Panel plugin displaying date, time and small calendar"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

xfce44
xfce44_goodies_panel_plugin

DOCS="AUTHORS ChangeLog NEWS README THANKS"
