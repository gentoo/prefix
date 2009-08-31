# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-places-plugin/xfce4-places-plugin-1.2.0.ebuild,v 1.7 2009/08/30 16:07:51 nixnut Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Places menu plug-in for panel, like GNOME's"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-places-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/1.2/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-4.3.90.2
	>=xfce-base/libxfcegui4-4.3.90.2
	xfce-base/thunar
	>=xfce-base/exo-0.3.1.1
	>=xfce-base/xfce4-panel-4.5.92"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
