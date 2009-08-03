# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.14.1-r1.ebuild,v 1.1 2009/07/26 23:24:07 eva Exp $

EAPI="2"

inherit autotools eutils flag-o-matic gnome.org python virtualx

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.8.0
	>=x11-libs/pango-1.16.0
	>=dev-libs/atk-1.12.0
	>=x11-libs/gtk+-2.13.6
	>=gnome-base/libglade-2.5.0
	>=dev-lang/python-2.4.4-r5
	>=dev-python/pycairo-1.0.2
	>=dev-python/pygobject-2.15.3
	dev-python/numpy"

DEPEND="${RDEPEND}
	doc? (
		dev-libs/libxslt
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9"

src_prepare() {
	# Fix declaration of codegen in .pc
	epatch "${FILESDIR}/${PN}-2.13.0-fix-codegen-location.patch"

	# Fix test failurs due to ltihooks
	# gentoo bug #268315, upstream bug #565593
	epatch "${FILESDIR}/${P}-ltihooks.patch"

	# Switch to numpy, bug #185692
	epatch "${FILESDIR}/${P}-numpy.patch"
	epatch "${FILESDIR}/${P}-fix-numpy-warning.patch"

	# Fix bug with GtkToggleButton and gtk+-2.16, bug #275449
	epatch "${FILESDIR}/${P}-gtktoggle.patch"

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile

	AT_M4DIR="m4" eautoreconf
}

src_configure() {
	use hppa && append-flags -ffunction-sections
	econf $(use_enable doc docs) --enable-thread
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	cd tests
	Xemake check-local || die "tests failed"
}

pkg_postinst() {
	python_version
	python_need_rebuild
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gtk-2.0
	rm -f "${EROOT}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.{py,pth}
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
}
