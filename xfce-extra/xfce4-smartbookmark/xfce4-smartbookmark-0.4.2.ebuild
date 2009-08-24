# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-smartbookmark/xfce4-smartbookmark-0.4.2.ebuild,v 1.20 2009/08/23 21:28:14 ssuominen Exp $

inherit xfce44

xfce44
xfce44_gzipped
xfce44_goodies_panel_plugin

DESCRIPTION="Xfce panel smart-bookmark plugin"
HOMEPAGE="http://www.xfce.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="xfce-base/xfce-utils"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	sed -i -e 's:bugs.debian:bugs.gentoo:g' "${S}"/src/smartbookmark.c
}
