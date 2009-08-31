# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-eyes-plugin/xfce4-eyes-plugin-4.4.0.ebuild,v 1.2 2009/08/25 08:44:55 ssuominen Exp $

EAUTORECONF=yes
EINTLTOOLIZE=yes
EAPI=2
inherit xfconf

DESCRIPTION="panel plugin that adds eyes which watch your every step"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/4.4/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/xfce4-panel-4.3.99.1
	>=xfce-base/libxfce4util-4.3.90.2
	>=xfce-base/libxfcegui4-4.3.90.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	PATCHES=( "${FILESDIR}/${P}-libtool.patch" )
	DOCS="AUTHORS ChangeLog README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}

src_prepare() {
	sed -i -e "/^AC_INIT/s/eyes_version()/eyes_version/" \
		configure.in || die "sed failed"
	xfconf_src_prepare
}
