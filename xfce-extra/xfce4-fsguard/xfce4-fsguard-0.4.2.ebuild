# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-fsguard/xfce4-fsguard-0.4.2.ebuild,v 1.3 2009/01/13 15:37:23 ranger Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Filesystem guard panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
