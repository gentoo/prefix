# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-time-out-plugin/xfce4-time-out-plugin-0.1.1.ebuild,v 1.1 2009/08/25 13:13:15 ssuominen Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Panel plugin to take a break from computer work"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.1/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.8:2
	>=xfce-base/xfce4-panel-4.3.99.2
	>=xfce-base/libxfce4util-4.3.99.2
	>=xfce-base/libxfcegui4-4.3.99.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
