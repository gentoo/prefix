# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/dia/dia-0.97.1.ebuild,v 1.8 2010/03/09 19:57:07 josejx Exp $

EAPI="2"

inherit eutils gnome2 libtool autotools versionator python

MY_P=${P/_/-}
DESCRIPTION="Diagram/flowchart creation program"
HOMEPAGE="http://www.gnome.org/projects/dia/"
LICENSE="GPL-2"

# dia used -1 instead of .1 for the new version.
MY_PV_MM=$(get_version_component_range 1-2)
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV_MM}/${MY_P}.tar.bz2"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
# the doc USE flag doesn't seem to do anything without docbook2html
# FIXME: configure mixes debug and devel meaning (see -DGTK_DISABLE...)
IUSE="cairo doc gnome png python zlib"

RDEPEND=">=x11-libs/gtk+-2.6.0
	>=dev-libs/glib-2.6.0
	>=x11-libs/pango-1.8
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
	cairo? ( >=x11-libs/cairo-1 )
	python? (
		>=dev-lang/python-1.5.2
		>=dev-python/pygtk-1.99 )
	doc? (
		~app-text/docbook-xml-dtd-4.5
		 app-text/docbook-xsl-stylesheets )"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35.0
	dev-util/pkgconfig
	doc? ( dev-libs/libxslt )"

DOCS="AUTHORS ChangeLog KNOWN_BUGS MAINTAINERS NEWS README RELEASE-PROCESS THANKS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_with cairo)
		$(use_with python)
		$(use_enable doc db2html)
		$(use_enable gnome)
		--disable-libemf
		--without-swig
		--without-hardbooks
		--disable-static
		--docdir=${EPREFIX}/usr/share/doc/${PF}
		--exec-prefix=${EPREFIX}/usr"
	# --exec-prefix makes Python look for modules in the Prefix
}

src_prepare() {
	gnome2_src_prepare

	# Fix compilation in a gnome environment, bug #159831
	epatch "${FILESDIR}/${PN}-0.97.0-gnome-doc.patch"

	# Fix compilation with USE="python", bug #271855
	if use python; then
		epatch "${FILESDIR}/${PN}-0.97-acinclude-python-fixes.patch"
	fi

	# Skip man generation
	if ! use doc; then
		sed -i -e '/if HAVE_DB2MAN/,/endif/d' doc/*/Makefile.am \
			|| die "sed 2 failed"
	fi

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

pkg_postinst() {
	gnome2_pkg_postinst
	if use python; then
		python_need_rebuild
		python_mod_optimize /usr/share/dia
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup /usr/share/dia
}
