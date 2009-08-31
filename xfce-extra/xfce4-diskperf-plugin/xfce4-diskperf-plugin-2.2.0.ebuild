# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-diskperf-plugin/xfce4-diskperf-plugin-2.2.0.ebuild,v 1.1 2009/08/25 13:38:35 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Disk usage and performance panel plugin"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/2.2/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=xfce-base/xfce4-panel-4.3.90"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
