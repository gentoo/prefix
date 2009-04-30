# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/ghex/ghex-2.24.0.ebuild,v 1.2 2009/04/28 15:22:25 jer Exp $

GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Gnome hexadecimal editor"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.4
	dev-libs/popt
	>=dev-libs/atk-1
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/libgnomeprintui-2.2
	>=gnome-base/gail-0.17"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	app-text/scrollkeeper
	>=dev-util/intltool-0.35
	>=app-text/gnome-doc-utils-0.3.2"

DOCS="AUTHORS ChangeLog NEWS README"

G2CONF="${G2CONF} --disable-static"
