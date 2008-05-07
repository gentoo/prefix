# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-clipman/xfce4-clipman-0.8.1.ebuild,v 1.2 2008/04/10 14:42:44 drac Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="a simple cliboard history manager for Xfce4 Panel"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-freebsd ~x86-linux"

DOCS="AUTHORS ChangeLog README THANKS"

xfce44_goodies_panel_plugin
