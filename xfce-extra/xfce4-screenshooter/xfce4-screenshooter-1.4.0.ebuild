# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.4.0.ebuild,v 1.7 2009/02/04 21:19:18 armin76 Exp $

inherit eutils xfce44

xfce44
xfce44_gzipped

DESCRIPTION="Xfce4 panel screenshooter plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
