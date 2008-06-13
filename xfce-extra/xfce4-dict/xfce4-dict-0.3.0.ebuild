# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-dict/xfce4-dict-0.3.0.ebuild,v 1.2 2008/05/04 11:11:05 drac Exp $

EAPI="prefix"

inherit xfce44

xfce44
xfce44_gzipped

DESCRIPTION="A plugin to query a Dict server and other dictionary sources"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="dev-util/intltool"

DOCS="AUTHORS ChangeLog README"

src_unpack() {
	unpack ${A}
	echo panel-plugin/aspell.c >> "${S}"/po/POTFILES.skip
}

xfce44_goodies_panel_plugin
