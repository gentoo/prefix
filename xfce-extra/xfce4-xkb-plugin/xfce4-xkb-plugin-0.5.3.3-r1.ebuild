# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-xkb-plugin/xfce4-xkb-plugin-0.5.3.3-r1.ebuild,v 1.2 2009/08/26 03:39:44 darkside Exp $

EAPI=2
inherit xfconf

DESCRIPTION="XKB layout switching panel plugin"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-xkb-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.5/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/xfce4-panel-4.3.20
	>=xfce-base/libxfce4util-4.3.90.2
	>=xfce-base/libxfcegui4-4.3.90.2
	>=x11-libs/libxklavier-4
	x11-libs/libwnck"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	x11-proto/kbproto
	>=gnome-base/librsvg-2.18"

pkg_setup() {
	DOCS="AUTHORS ChangeLog README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
	PATCHES=( "${FILESDIR}/${P}-libxklavier.patch" )
}
