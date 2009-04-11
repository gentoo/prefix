# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/dia/dia-0.95.1.ebuild,v 1.11 2008/03/09 16:21:33 leio Exp $

inherit eutils gnome2 libtool autotools versionator

DESCRIPTION="Diagram/flowchart creation program"
HOMEPAGE="http://www.gnome.org/projects/dia/"
LICENSE="GPL-2"

# dia used -1 instead of .1 for the new version.
MY_PV=$(replace_version_separator 2 '-' )
MY_PV_MM=$(get_version_component_range 1-2 )
MY_P="${PN}-${MY_PV}"
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV_MM}/${PN}-${MY_PV}.tar.bz2"

SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE="gnome png python zlib"

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
	python? ( >=dev-lang/python-1.5.2
		>=dev-python/pygtk-1.99 )
	~app-text/docbook-xml-dtd-4.2
	app-text/docbook-xsl-stylesheets"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.21
	dev-util/pkgconfig"

G2CONF="${G2CONF} $(use_enable gnome) $(use_with python)"

DOCS="AUTHORS ChangeLog COPYING KNOWN_BUGS MAINTAINERS NEWS README RELEASE-PROCESS THANKS TODO"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	gnome2_src_unpack

	# Disable python -c 'import gtk' during compile to prevent using
	# X being involved (#31589)
	# changed the patch to a sed to make it a bit more portable - AllanonJL
	sed -i -e '/AM_CHECK_PYMOD/d' configure.in

	eautoreconf
	intltoolize --force || die "intltoolize failed"
}
