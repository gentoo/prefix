# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.16.1.ebuild,v 1.8 2009/04/27 13:11:12 jer Exp $

inherit autotools gnome2 python virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc examples" # libffi

RDEPEND=">=dev-lang/python-2.4.4-r5
	>=dev-libs/glib-2.16
	!<dev-python/pygtk-2.13"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.12.0"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
#	if use libffi && ! built_with_use sys-devel/gcc libffi; then
#		eerror "libffi support not found in sys-devel/gcc." && die
#	fi

	G2CONF="${G2CONF} $(use_enable doc docs)" # $(use_with libffi ffi)
}

src_unpack() {
	gnome2_src_unpack

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	# needed to build on a libtool-1 system, bug #255542
	rm m4/lt* m4/libtool.m4 ltmain.sh

	eautoreconf

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "tests failed"
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

	if [[ ${CHOST} == *-darwin* ]] ; then
		# our python expects a bundle
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gio/_gio.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gio/unix.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/glib/_glib.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gobject/_gobject.{so,bundle}
	fi
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
	python_mod_compile /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py
	python_need_rebuild
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
