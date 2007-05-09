# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-menus/gnome-menus-2.18.0.ebuild,v 1.1 2007/03/24 19:37:25 dang Exp $

EAPI="prefix"

inherit eutils gnome2

DESCRIPTION="The GNOME menu system, implementing the F.D.O cross-desktop spec"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="debug python"

RDEPEND=">=dev-libs/glib-2.6
	python? (
				>=dev-lang/python-2.2
				dev-python/pygtk
			)"
DEPEND="${RDEPEND}
	  sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="--enable-inotify $(use_enable debug) $(use_enable python)"
}
