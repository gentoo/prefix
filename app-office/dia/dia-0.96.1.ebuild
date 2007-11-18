# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/dia/dia-0.96.1.ebuild,v 1.2 2007/11/17 18:30:06 eva Exp $

EAPI="prefix"

inherit eutils gnome2 libtool autotools versionator

DESCRIPTION="Diagram/flowchart creation program"
HOMEPAGE="http://www.gnome.org/projects/dia/"
LICENSE="GPL-2"

# dia used -1 instead of .1 for the new version.
MY_PV_MM=$(get_version_component_range 1-2 )
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV_MM}/${P}.tar.bz2"

SLOT="0"
KEYWORDS=""
IUSE="doc gnome png python zlib cairo gnome-print"

RDEPEND=">=x11-libs/gtk+-2.6.0
	>=dev-libs/glib-2.6.0
	>=x11-libs/pango-1.1.5
	>=dev-libs/libxml2-2.3.9
	>=dev-libs/libxslt-1
	>=media-libs/freetype-2.0.95
	dev-libs/popt
	zlib? ( sys-libs/zlib )
	png? ( media-libs/libpng
		>=media-libs/libart_lgpl-2 )
	gnome? ( >=gnome-base/libgnome-2.0
		>=gnome-base/libgnomeui-2.0 )
	gnome-print? ( gnome-base/libgnomeprint )
	cairo? ( x11-libs/cairo )
	python? ( >=dev-lang/python-1.5.2
		>=dev-python/pygtk-1.99 )
	doc? (
		~app-text/docbook-xml-dtd-4.2
		app-text/docbook-xsl-stylesheets )"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.21
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog COPYING KNOWN_BUGS MAINTAINERS NEWS README RELEASE-PROCESS THANKS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable gnome)
		$(use_with gnome-print gnomeprint)
		$(use_with python)
		$(use_with cairo)
		$(use_enable doc db2html)"
}

src_unpack() {
	gnome2_src_unpack

	# Disable python -c 'import gtk' during compile to prevent using
	# X being involved (#31589)
	# changed the patch to a sed to make it a bit more portable - AllanonJL
	sed -i -e '/AM_CHECK_PYMOD/d' configure.in

	eautoreconf
}
