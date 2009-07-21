# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/bubblemon/bubblemon-2.0.14.ebuild,v 1.1 2009/07/18 22:10:43 ssuominen Exp $

EAPI=2
GCONF_DEBUG=no
inherit gnome2

DESCRIPTION="A fun monitoring applet for your desktop, complete with swimming duck"
HOMEPAGE="http://www.nongnu.org/bubblemon"
SRC_URI="http://download.savannah.gnu.org/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls"

RDEPEND="x11-libs/gtk+:2
	gnome-base/gnome-panel
	gnome-base/libgnomeui
	gnome-base/libgtop"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( dev-util/intltool
		sys-devel/gettext )"

pkg_setup() {
	DOCS="AUTHORS ChangeLog TRANSLATIONS README TODO"
	G2CONF="$(use_enable nls)"
}

src_prepare() {
	gnome2_src_prepare
	sed -i -e 's:-g -O2 -Wall -Werror:-Wall:' configure || die "sed failed"
}
