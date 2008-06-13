# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-time-out/xfce4-time-out-0.1.1.ebuild,v 1.8 2007/10/15 16:29:27 drac Exp $

EAPI="prefix"

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
