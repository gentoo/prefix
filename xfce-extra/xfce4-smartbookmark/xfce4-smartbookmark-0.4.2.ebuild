# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-smartbookmark/xfce4-smartbookmark-0.4.2.ebuild,v 1.19 2007/05/18 12:03:35 armin76 Exp $

EAPI="prefix"

inherit xfce44

xfce44
xfce44_gzipped
xfce44_goodies_panel_plugin

DESCRIPTION="Xfce panel smart-bookmark plugin"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

RDEPEND="xfce-base/xfce-utils"

src_unpack() {
	unpack ${A}
	sed -i -e 's:bugs.debian:bugs.gentoo:g' "${S}"/src/smartbookmark.c
}
