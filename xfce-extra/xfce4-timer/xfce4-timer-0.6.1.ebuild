# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-timer/xfce4-timer-0.6.1.ebuild,v 1.8 2009/02/09 20:04:52 angelos Exp $

inherit xfce44

xfce44

DESCRIPTION="Timer panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="dev-util/intltool"
RDEPEND=""

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
