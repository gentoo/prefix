# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-clipman-plugin/xfce4-clipman-plugin-1.0.2.ebuild,v 1.8 2009/08/30 16:06:32 nixnut Exp $

EAPI=2
inherit xfconf

DESCRIPTION="a simple cliboard history manager for Xfce4 Panel"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-clipman-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/1.0/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.14:2
	>=gnome-base/libglade-2.6:2.0
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/xfce4-panel-4.4
	>=xfce-base/xfconf-4.6
	>=xfce-base/exo-0.3"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
