# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.14.2.ebuild,v 1.2 2008/05/29 14:23:41 hawking Exp $

EAPI="prefix"

inherit gnome2 python autotools

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples libffi"

# glib higher dep than in configure.in comes from a runtime version check and ensures that
# timeout_add_seconds is available for any packages that depend on pygobject and use it
# python high dep for a fixed python-config, as aclocal.m4/configure in the tarball requires it to function properly
RDEPEND=">=dev-lang/python-2.4.4-r5
	>=dev-libs/glib-2.13.5
	!<dev-python/pygtk-2.9"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.12.0"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	if use libffi && ! built_with_use sys-devel/gcc libffi; then
		eerror "libffi support not found in sys-devel/gcc." && die
	fi

	G2CONF="${G2CONF} $(use_enable doc docs) $(use_with libffi ffi)"
}

src_unpack() {
	gnome2_src_unpack

	# fix bug #147285 - Robin H. Johnson <robbat2@gentoo.org>
	# this is caused by upstream's automake-1.8 lacking some Gentoo-specific
	# patches (for tmpfs amongst other things). Upstreams hit by this should
	# move to newer automake versions ideally.
	AT_M4DIR="m4" eautomake

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

src_install() {
	gnome2_src_install

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples
	fi

	python_version
	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py-2.0
	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth-2.0
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
	python_mod_compile /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
