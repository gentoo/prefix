# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtksourceview/pygtksourceview-2.4.0.ebuild,v 1.8 2009/04/12 20:58:44 bluebird Exp $

inherit gnome2 python flag-o-matic multilib

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

SRC_URI="${SRC_URI}"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=dev-python/pygobject-2.15.2
	>=dev-python/pygtk-2.8
	>=x11-libs/gtksourceview-2.3"

DEPEND="${RDEPEND}
	doc? (
		>=dev-util/gtk-doc-1.10
		dev-libs/libxslt
		~app-text/docbook-xml-dtd-4.1.2
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable doc docs)"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/
	python_need_rebuild
}

pkg_postrm() {
	python_mod_cleanup
}
