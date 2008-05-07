# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-genmon/xfce4-genmon-3.2.ebuild,v 1.3 2008/04/10 14:44:58 drac Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Cyclically spawns the executable, captures its output and displays the result into the panel."
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-freebsd ~x86-linux"

RDEPEND=">=xfce-base/xfce4-panel-4.3.22"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

DOCS="AUTHORS ChangeLog README"

xfce44_goodies_panel_plugin
