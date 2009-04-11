# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-clipman/xfce4-clipman-0.8.1.ebuild,v 1.10 2008/11/08 15:13:28 angelos Exp $

inherit xfce44

xfce44

DESCRIPTION="a simple cliboard history manager for Xfce4 Panel"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DOCS="AUTHORS ChangeLog README THANKS"

xfce44_goodies_panel_plugin
