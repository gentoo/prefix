# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-fsguard/xfce4-fsguard-0.4.1.ebuild,v 1.9 2008/03/26 11:55:08 jer Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="Filesystem guard panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
