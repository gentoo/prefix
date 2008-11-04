# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-timer/xfce4-timer-0.6.ebuild,v 1.9 2008/11/04 01:00:27 vapier Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Timer panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

DEPEND="dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
