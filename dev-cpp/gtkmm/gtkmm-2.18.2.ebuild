# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gtkmm/gtkmm-2.18.2.ebuild,v 1.1 2009/10/29 22:51:24 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="C++ interface for GTK+2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc examples test"

RDEPEND=">=dev-cpp/glibmm-2.22
	>=x11-libs/gtk+-2.18
	>=dev-cpp/cairomm-1.2.2
	>=dev-cpp/pangomm-2.26
	>=dev-libs/atk-1.9.1
	dev-libs/libsigc++:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen )"

DOCS="AUTHORS CHANGES ChangeLog PORTING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--enable-api-atkmm
		--disable-maintainer-mode
		$(use_enable doc documentation)"
}

src_prepare() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed 1 failed"
	fi

	if ! use examples; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)demos\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed 2 failed"
	fi
}
