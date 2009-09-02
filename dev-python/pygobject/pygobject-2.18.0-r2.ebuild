# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.18.0-r2.ebuild,v 1.1 2009/08/28 17:15:30 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit alternatives autotools gnome2 python virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples libffi test"

RDEPEND=">=dev-lang/python-2.4.4-r5
	>=dev-libs/glib-2.16
	!<dev-python/pygtk-2.13
	libffi? ( virtual/libffi )"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	test? ( media-fonts/font-cursor-misc media-fonts/font-misc-misc )
	>=dev-util/pkgconfig-0.12.0"

RESTRICT_PYTHON_ABIS="3*"

DOCS="AUTHORS ChangeLog* NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		$(use_enable doc docs)
		$(use_with libffi ffi)"
}

src_prepare() {
	gnome2_src_prepare

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}"/${P}-make_check.patch

	# Do not install files twice, bug #279813
	epatch "${FILESDIR}/${P}-automake111.patch"

	# Support installation for multiple Python versions
	epatch "${FILESDIR}/${P}-support_multiple_python_versions.patch"

	# needed to build on a libtool-1 system, bug #255542
	rm m4/lt* m4/libtool.m4 ltmain.sh

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile

	eautoreconf

	python_copy_sources
}

src_configure() {
	python_execute_function -s gnome2_src_configure
}

src_compile() {
	python_execute_function -d -s
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS

	testing() {
		if has ${PYTHON_ABI} 2.4 2.5; then
			einfo "Skipping tests with Python ${PYTHON_ABI}. dev-python/pycairo supports only Python >=2.6."
			return 0
		fi

		Xemake check
	}
	python_execute_function -s testing
}

src_install() {
	installation() {
		gnome2_src_install
		mv "${D}$(python_get_sitedir)/pygtk.py" "${D}$(python_get_sitedir)/pygtk.py-2.0"
		mv "${D}$(python_get_sitedir)/pygtk.pth" "${D}$(python_get_sitedir)/pygtk.pth-2.0"
	}
	python_execute_function -s installation

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples
	fi

	if [[ ${CHOST} == *-darwin* ]] ; then
		# our python expects a bundle
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gio/_gio.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gio/unix.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/glib/_glib.{so,bundle}
		mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0/gobject/_gobject.{so,bundle}
	fi
}

pkg_postinst() {
	python_need_rebuild

	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks

	python_mod_optimize gtk-2.0 pygtk.py
}

pkg_postrm() {
	python_mod_cleanup

	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks
}
