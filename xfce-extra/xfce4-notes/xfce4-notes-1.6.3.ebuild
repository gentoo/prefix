# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-notes/xfce4-notes-1.6.3.ebuild,v 1.2 2009/01/12 00:09:13 darkside Exp $

EAPI="prefix"

inherit xfce44

DESCRIPTION="Xfce4 panel sticky notes plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44
xfce44_goodies_panel_plugin
