# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonobo/libbonobo-2.20.1.ebuild,v 1.4 2007/11/22 14:05:17 armin76 Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="GNOME CORBA framework"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc-solaris ~x86"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.8
	>=gnome-base/orbit-2.14.0
	>=dev-libs/libxml2-2.4.20
	>=dev-libs/popt-1.5
	!gnome-base/bonobo-activation"
DEPEND="${RDEPEND}
	  x11-apps/xrdb
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="$(use_enable debug bonobo-activation-debug)"
}
