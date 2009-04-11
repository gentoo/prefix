# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-icon-theme/xfce4-icon-theme-4.4.2.ebuild,v 1.7 2007/12/17 18:49:38 jer Exp $

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

DESCRIPTION="Icon theme"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
RESTRICT="binchecks strip"

RDEPEND="x11-themes/hicolor-icon-theme"
DEPEND="dev-util/pkgconfig
	dev-util/intltool"

DOCS="AUTHORS ChangeLog NEWS README TODO"

xfce44_core_package
