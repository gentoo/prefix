# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libglade/libglade-2.6.4.ebuild,v 1.15 2012/05/12 20:19:54 aballier Exp $

EAPI="3"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_DEPEND="2"

inherit autotools eutils gnome2 python virtualx flag-o-matic autotools

DESCRIPTION="Library to construct graphical interfaces at runtime"
HOMEPAGE="http://library.gnome.org/devel/libglade/stable/"

LICENSE="LGPL-2"
SLOT="2.0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc static-libs test"

RDEPEND=">=dev-libs/glib-2.10:2
	>=x11-libs/gtk+-2.8.10:2
	>=dev-libs/atk-1.9
	>=dev-libs/libxml2-2.4.10"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	gnome-base/gnome-common
	doc? ( >=dev-util/gtk-doc-1 )"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable static-libs static)"
	DOCS="AUTHORS ChangeLog NEWS README"
	python_set_active_version 2
}

src_prepare() {
	# patch to stop make install installing the xml catalog
	# because we do it ourselves in postinst()
	epatch "${FILESDIR}"/Makefile.in.am-2.4.2-xmlcatalog.patch

	# patch to not throw a warning with gtk+-2.14 during tests, as it triggers abort
	epatch "${FILESDIR}/${PN}-2.6.3-fix_tests-page_size.patch"

	# Fails with gold due to recent changes in glib-2.32's pkg-config files
	epatch "${FILESDIR}/${P}-gold-glib-2.32.patch"

	sed -i -e 's:-D[A-Z_]*DISABLE_DEPRECATED:$(NULL):g' \
		glade/Makefile.am glade/Makefile.in || die

	if ! use test; then
		sed 's/ tests//' -i Makefile.am Makefile.in || die "sed failed"
	fi

	#eautoreconf # need new libtool for interix

	# Needed for solaris, else gcc finds a syntax error in /usr/include/signal.h

	[[ ${CHOST} == *-solaris* ]] && append-flags "-D__EXTENSIONS__"

	gnome2_src_prepare
	AT_NOELIBTOOLIZE=yes eautoreconf
}

src_test() {
	Xemake check || die "make check failed"
}

src_install() {
	dodir /etc/xml
	gnome2_src_install
	python_convert_shebangs 2 "${ED}"/usr/bin/libglade-convert
}

pkg_postinst() {
	echo ">>> Updating XML catalog"
	"${EPREFIX}"/usr/bin/xmlcatalog --noout --add "system" \
		"http://glade.gnome.org/glade-2.0.dtd" \
		"${EPREFIX}"/usr/share/xml/libglade/glade-2.0.dtd "${EPREFIX}"/etc/xml/catalog
	gnome2_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm
	echo ">>> removing entries from the XML catalog"
	"${EPREFIX}"/usr/bin/xmlcatalog --noout --del \
		"${EPREFIX}"/usr/share/xml/libglade/glade-2.0.dtd "${EPREFIX}"/etc/xml/catalog
}
