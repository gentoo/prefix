# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-cpugraph/xfce4-cpugraph-0.4.0.ebuild,v 1.9 2009/08/23 21:37:41 ssuominen Exp $

inherit xfce44

xfce44
xfce44_gzipped

DESCRIPTION="CPU load panel plugin"
HOMEPAGE="http://www.xfce.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_goodies_panel_plugin
