# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mount-plugin/xfce4-mount-plugin-0.5.5.ebuild,v 1.1 2009/08/24 13:28:44 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Mount plugin for Xfce4 panel"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.5/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=xfce-base/libxfcegui4-4.3.20
	>=xfce-base/xfce4-panel-4.3.20"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
