# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-timer/xfce4-timer-0.6.ebuild,v 1.8 2008/03/26 11:53:10 jer Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Timer panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

DEPEND="dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
