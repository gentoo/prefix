# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-quicklauncher/xfce4-quicklauncher-1.9.4.ebuild,v 1.14 2009/08/23 21:27:06 ssuominen Exp $

inherit autotools xfce44

xfce44
xfce44_goodies_panel_plugin

DESCRIPTION="Xfce4 panel quicklauncher plugin"
HOMEPAGE="http://www.xfce.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="xfce-base/xfce4-panel"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/xfce4-dev-tools
	dev-util/intltool"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "/^AC_INIT/s/quicklauncher_version()/quicklauncher_version/" configure.ac
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}

DOCS="AUTHORS NEWS README TODO"
