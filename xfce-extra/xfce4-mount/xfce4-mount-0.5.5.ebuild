# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mount/xfce4-mount-0.5.5.ebuild,v 1.8 2008/09/26 13:35:56 jer Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Mount plug-in for panel"
KEYWORDS="~amd64-linux ~x86-linux"

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"

xfce44_goodies_panel_plugin
