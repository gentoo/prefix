# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/dia/dia-0.96.1-r1.ebuild,v 1.7 2008/05/29 15:46:28 hawking Exp $

EAPI="prefix"

inherit eutils gnome2 libtool autotools versionator python

DESCRIPTION="Diagram/flowchart creation program"
HOMEPAGE="http://www.gnome.org/projects/dia/"
LICENSE="GPL-2"

# dia used -1 instead of .1 for the new version.
MY_PV_MM=$(get_version_component_range 1-2 )
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV_MM}/${P}.tar.bz2"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
# the doc USE flag doesn't seem to do anything without docbook2html
IUSE="cairo doc gnome gnome-print png python zlib"

RDEPEND=">=x11-libs/gtk+-2.6.0
	>=dev-libs/glib-2.6.0
	>=x11-libs/pango-1.1.5
	>=dev-libs/libxml2-2.3.9
	>=dev-libs/libxslt-1
	>=media-libs/freetype-2.0.95
	dev-libs/popt
	zlib? ( sys-libs/zlib )
	png? (
		  media-libs/libpng
		>=media-libs/libart_lgpl-2 )
	gnome? (
		>=gnome-base/libgnome-2.0
		>=gnome-base/libgnomeui-2.0 )
	gnome-print? ( gnome-base/libgnomeprint )
	cairo? ( x11-libs/cairo )
	python? (
		>=dev-lang/python-1.5.2
		>=dev-python/pygtk-1.99 )
	doc? (
		~app-text/docbook-xml-dtd-4.2
		 app-text/docbook-xsl-stylesheets )"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.21
	  dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog KNOWN_BUGS MAINTAINERS NEWS README RELEASE-PROCESS THANKS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_with cairo)
		$(use_with python)
		$(use_enable doc db2html)
		$(use_enable gnome)
		$(use_with gnome-print gnomeprint)
		--exec-prefix=${EPREFIX}/usr"
	# --exec-prefix makes Python look for modules in the Prefix
}

src_unpack() {
	gnome2_src_unpack

	# Disable python -c 'import gtk' during compile to prevent using
	# X being involved (#31589)
	# changed the patch to a sed to make it a bit more portable - AllanonJL
	sed -i -e '/AM_CHECK_PYMOD/d' configure.in

	# Fix compilation in a gnome environment, bug #159831
	epatch "${FILESDIR}/${PN}-0.96.1-gnome-doc.patch"

	# Fix broken XML in documentation
	epatch "${FILESDIR}/${PN}-0.96.1-xml-fixes.patch"

	# Skip man generation
	use doc || sed -i -e '/if HAVE_DB2MAN/,/man_MANS/d' doc/*/Makefile.am

	# Fix tests
	echo "dia.desktop.in" >> po/POTFILES.skip

	eautoreconf
	intltoolize --force || die "intltoolize failed"
}

pkg_postinst() {
	gnome2_pkg_postinst
	use python && python_mod_optimize /usr/share/dia
}

pkg_postrm() {
	gnome2_pkg_postrm
	use python && python_mod_cleanup /usr/share/dia
}
