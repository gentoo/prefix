# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-python/pygobject/pygobject-2.12.3.ebuild,v 1.11 2007/01/18 23:48:38 jer Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=1.8
inherit gnome2 python eutils autotools

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE="doc"

RDEPEND=">=dev-lang/python-2.3.5
	>=dev-libs/glib-2.8
	!<dev-python/pygtk-2.9"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.12.0"

DOCS="AUTHORS ChangeLog INSTALL NEWS README"


pkg_setup() {
	G2CONF="$(use_enable doc docs)"
}

src_unpack() {
	gnome2_src_unpack

	# fix bug #147285 - Robin H. Johnson <robbat2@gentoo.org>
	# this is caused by upstream's automake-1.8 lacking some Gentoo-specific
	# patches (for tmpfs amongst other things). Upstreams hit by this should
	# move to newer automake versions ideally.
	eautomake

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $EROOT/bin/true py-compile
}

src_install() {
	gnome2_src_install

	insinto /usr/share/doc/${P}
	doins -r examples

	python_version
	mv ${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py \
		${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py-2.0
	mv ${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth \
		${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth-2.0
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/lib/python${PYVER}/site-packages/gtk-2.0
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
	python_mod_compile /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
