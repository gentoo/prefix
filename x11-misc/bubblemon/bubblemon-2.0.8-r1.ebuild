# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/bubblemon/bubblemon-2.0.8-r1.ebuild,v 1.1 2008/01/15 11:48:51 drac Exp $

inherit gnome2

DESCRIPTION="A fun monitoring applet for your desktop, complete with swimming duck"
HOMEPAGE="http://www.nongnu.org/bubblemon"
SRC_URI="http://download.savannah.gnu.org/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6
        >=x11-libs/gtk+-2.8
        >=gnome-base/gnome-panel-2
        >=gnome-base/libgnome-2.8
        >=gnome-base/libgnomeui-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog TRANSLATIONS README TODO"
