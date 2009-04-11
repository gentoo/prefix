# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-time-out/xfce4-time-out-0.1.1.ebuild,v 1.9 2008/08/08 17:51:25 aballier Exp $

inherit xfce44

xfce44

DESCRIPTION="Panel plugin to take a break from computer work."
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-lang/perl"

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"

xfce44_goodies_panel_plugin
