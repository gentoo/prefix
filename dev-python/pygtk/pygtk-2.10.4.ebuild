# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.10.4.ebuild,v 1.9 2007/05/31 03:52:05 dang Exp $

EAPI="prefix"

NEED_PYTHON=2.3.5

inherit gnome.org python flag-o-matic

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

DOC_FILE="pygtk2reference-2.9.0.tar.bz2"
SRC_URI="${SRC_URI}
	doc? ( mirror://gnome/sources/pygtk2reference/2.9/${DOC_FILE} )"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE="doc examples opengl"

RDEPEND=">=dev-libs/glib-2.8.0
	>=x11-libs/pango-1.10.0
	>=dev-libs/atk-1.8.0
	>=x11-libs/gtk+-2.10.0
	>=gnome-base/libglade-2.5.0
	>=dev-python/pycairo-1.0.2
	>=dev-python/pygobject-2.12.1
	!arm? ( dev-python/numeric )
	opengl?	(	virtual/opengl
				dev-python/pyopengl
				>=x11-libs/gtkglarea-1.99
			)"

DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9"

# Tests fail (missing display)
RESTRICT="test"

src_unpack() {
	unpack ${A}
	use doc || sed -e 's/\(SUBDIRS =.*\) docs$/\1/' -i "${S}"/Makefile.am

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s ${EROOT}/bin/true "${S}"/py-compile
}

src_compile() {
	use hppa && append-flags -ffunction-sections
	econf $(use_enable doc docs) --enable-thread || die
	# possible problems with parallel builds (#45776)
	emake -j1 || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	if use doc; then
		insinto /usr/share/gtk-doc/html/pygtk
		cd "${WORKDIR}"/pygtk2reference
		doins -r cursors icons images
	fi
}

src_test() {
	cd tests
	make check-local || die "tests failed"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/share/pygtk/2.0/codegen /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/share/pygtk/2.0/codegen
	python_mod_cleanup
	rm -f ${EROOT}/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.{py,pth}
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
}
