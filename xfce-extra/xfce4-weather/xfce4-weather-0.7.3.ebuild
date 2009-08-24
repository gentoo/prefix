# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-weather/xfce4-weather-0.7.3.ebuild,v 1.3 2009/08/23 16:47:30 ssuominen Exp $

EINTLTOOLIZE="yes"
EAUTORECONF="yes"

MY_P=${PN}-plugin-${PV}

inherit xfconf

DESCRIPTION="panel plugin that shows the current temperature and weather condition."
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-weather-plugin"
SRC_URI="http://archive.xfce.org/src/panel-plugins/${PN}-plugin/0.7/${PN}-plugin-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=xfce-base/xfce4-panel-4.3.99.1
	>=xfce-base/libxfcegui4-4.3.90.2
	>=xfce-base/libxfce4util-4.3.90.2
	dev-libs/libxml2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS README TODO"
}
