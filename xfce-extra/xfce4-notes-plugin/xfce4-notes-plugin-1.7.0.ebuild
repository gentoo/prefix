# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-notes-plugin/xfce4-notes-plugin-1.7.0.ebuild,v 1.7 2009/09/05 15:34:00 ranger Exp $

EAPI=2
inherit xfconf

DESCRIPTION="Xfce4 panel sticky notes plugin"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-notes-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/1.7/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.10:2
	>=xfce-base/xfce4-panel-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/xfconf-4.6
	>=xfce-base/libxfcegui4-4.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
