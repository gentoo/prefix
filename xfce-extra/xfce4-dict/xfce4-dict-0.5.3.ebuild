# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-dict/xfce4-dict-0.5.3.ebuild,v 1.9 2009/09/05 15:34:31 ranger Exp $

EAPI=2
inherit xfconf

DESCRIPTION="plugin and stand-alone application to query dict.org"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-dict "
SRC_URI="mirror://xfce/src/apps/${PN}/0.5/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/xfce4-panel-4.4"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

pkg_setup() {
	DOCS="AUTHORS ChangeLog README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}
