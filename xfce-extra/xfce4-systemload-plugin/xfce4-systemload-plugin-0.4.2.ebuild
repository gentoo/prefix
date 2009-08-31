# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-systemload-plugin/xfce4-systemload-plugin-0.4.2.ebuild,v 1.1 2009/08/25 13:03:49 ssuominen Exp $

EAUTORECONF=yes
EINTLTOOLIZE=yes
EAPI=2
inherit xfconf

DESCRIPTION="System load monitor panel plugin"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="http://www.us.xfce.org/archive/src/panel-plugins/xfce4-systemload-plugin/0.4/xfce4-systemload-plugin-0.4.2.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/xfce4-panel-4.3.99.1
	>=xfce-base/libxfcegui4-4.3.99.1
	>=xfce-base/libxfce4util-4.3.99.1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	PATCHES=( "${FILESDIR}/${P}-libtool.patch" )
	DOCS="AUTHORS ChangeLog NEWS README"
	XFCONF="--disable-dependency-tracking
		$(use_enable debug)"
}

src_prepare() {
	sed -i -e "/^AC_INIT/s/systemload_version()/systemload_version/" \
		configure.in || die "sed failed"
	xfconf_src_prepare
}
