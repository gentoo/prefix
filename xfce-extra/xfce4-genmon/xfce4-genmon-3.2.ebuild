# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-genmon/xfce4-genmon-3.2.ebuild,v 1.13 2009/08/23 21:25:38 ssuominen Exp $

inherit xfce44

xfce44

DESCRIPTION="Cyclically spawns the executable, captures its output and displays the result into the panel."
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
RDEPEND=">=xfce-base/xfce4-panel-4.3.22"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog README"

xfce44_goodies_panel_plugin
