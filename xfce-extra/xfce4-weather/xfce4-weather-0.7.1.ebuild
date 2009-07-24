# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-weather/xfce4-weather-0.7.1.ebuild,v 1.1 2009/07/22 20:43:26 billie Exp $

inherit autotools xfce4

xfce4_panel_plugin

DESCRIPTION="Weather monitor panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

DOCS="AUTHORS ChangeLog NEWS README TODO"

RDEPEND=">=xfce-base/xfce4-panel-4.3.99.1"
DEPEND="${RDEPEND}
	dev-libs/libxml2
	dev-util/intltool
	dev-util/xfce4-dev-tools
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"
	intltoolize --force --copy --automake || die "intltoolize failed"
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}
