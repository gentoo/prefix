# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-verve-plugin/xfce4-verve-plugin-0.3.6.ebuild,v 1.1 2009/08/25 13:32:21 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Command line panel plugin"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.3/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="dbus debug"

RDEPEND=">=xfce-base/exo-0.3.1.3
	>=xfce-base/xfce4-panel-4.4
	>=xfce-base/libxfce4util-4.4
	>=dev-libs/libpcre-5
	dbus? ( >=dev-libs/dbus-glib-0.60 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable dbus)
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog README THANKS TODO"
}
