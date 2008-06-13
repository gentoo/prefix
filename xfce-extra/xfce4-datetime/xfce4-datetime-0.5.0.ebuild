# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-datetime/xfce4-datetime-0.5.0.ebuild,v 1.10 2007/03/17 21:33:06 vapier Exp $

EAPI="prefix"

inherit xfce44

DESCRIPTION="Panel plugin displaying date, time and small calendar"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

xfce44
xfce44_gzipped
xfce44_goodies_panel_plugin

DOCS="AUTHORS ChangeLog NEWS README"
