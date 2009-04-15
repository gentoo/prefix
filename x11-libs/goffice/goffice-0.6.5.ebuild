# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/goffice/goffice-0.6.5.ebuild,v 1.4 2009/04/13 01:06:50 mr_bones_ Exp $

EAPI=2

inherit eutils gnome2 flag-o-matic

DESCRIPTION="A library of document-centric objects and utilities"
HOMEPAGE="http://freshmeat.net/projects/goffice/"

LICENSE="GPL-2"
SLOT="0.6"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc gnome"

# Raising glib dep to 2.14 to drop pcre dependency
# cairo support broken and -gtk broken

RDEPEND=">=dev-libs/glib-2.14
	>=gnome-extra/libgsf-1.13.3[gnome?]
	>=dev-libs/libxml2-2.4.12
	>=x11-libs/pango-1.8.1
	>=x11-libs/gtk+-2.6
	>=gnome-base/libglade-2.3.6
	>=media-libs/libart_lgpl-2.3.11
	>=x11-libs/cairo-1.2[svg]
	gnome? (
		>=gnome-base/gconf-2
		>=gnome-base/libgnomeui-2 )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1.4 )"

DOCS="AUTHORS BUGS ChangeLog MAINTAINERS NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} $(use_with gnome)"
	filter-flags -ffast-math
}
