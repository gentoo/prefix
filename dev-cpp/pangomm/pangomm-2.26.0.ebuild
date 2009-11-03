# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/pangomm/pangomm-2.26.0.ebuild,v 1.1 2009/10/29 22:58:55 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="C++ interface for pango"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc"

RDEPEND=">=x11-libs/pango-1.23.0
	>=dev-cpp/glibmm-2.14.1
	>=dev-cpp/cairomm-1.2.2
	dev-libs/libsigc++:2
	!<dev-cpp/gtkmm-2.13:2.4"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README*"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		$(use_enable doc documentation)"
}
