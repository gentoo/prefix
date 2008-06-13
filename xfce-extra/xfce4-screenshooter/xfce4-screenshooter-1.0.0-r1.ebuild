# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.0.0-r1.ebuild,v 1.8 2007/10/15 16:26:42 drac Exp $

EAPI="prefix"

inherit eutils xfce44

xfce44

DESCRIPTION="Xfce4 panel screenshooter plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-cancel-save.patch
}

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
