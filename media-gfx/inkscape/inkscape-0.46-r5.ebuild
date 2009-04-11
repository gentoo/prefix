# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/inkscape/inkscape-0.46-r5.ebuild,v 1.11 2009/03/30 13:44:06 loki_val Exp $

EAPI=2

inherit gnome2 eutils

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="dia doc gnome inkjar jabber lcms mmx perl postscript spell wmf"
RESTRICT="test"

COMMON_DEPEND="
	>=virtual/poppler-glib-0.8.3[cairo]
	dev-cpp/glibmm
	>=dev-cpp/gtkmm-2.10.0
	>=dev-libs/boehm-gc-6.4
	dev-libs/boost
	>=dev-libs/glib-2.6.5
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml
	dev-python/pyxml
	media-gfx/imagemagick
	media-libs/fontconfig
	>=media-libs/freetype-2
	media-libs/libpng
	x11-libs/libXft
	>=x11-libs/gtk+-2.10.7
	>=x11-libs/pango-1.4.0
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	lcms? ( >=media-libs/lcms-1.14 )
	perl? (
		dev-perl/XML-Parser
		dev-perl/XML-XQL
	)
	spell? ( app-text/gtkspell )"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="
	${COMMON_DEPEND}
	dev-python/numpy
	dia? ( app-office/dia )
	postscript? ( >=media-gfx/pstoedit-3.44[plotutils] media-gfx/skencil )
	wmf? ( media-libs/libwmf )"

DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	dev-util/pkgconfig
	x11-libs/libX11
	>=dev-util/intltool-0.29"

pkg_setup() {
	G2CONF="${G2CONF} --with-xft"
	G2CONF="${G2CONF} $(use_with spell gtkspell)"
	G2CONF="${G2CONF} $(use_enable jabber inkboard)"
	G2CONF="${G2CONF} $(use_enable mmx)"
	G2CONF="${G2CONF} $(use_with inkjar)"
	G2CONF="${G2CONF} $(use_with gnome gnome-vfs)"
	G2CONF="${G2CONF} $(use_enable lcms)"
	G2CONF="${G2CONF} $(use_with perl)"
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc43.patch
	epatch "${FILESDIR}"/${P}-poppler-0.8.3.patch
	epatch "${FILESDIR}"/${P}-bug-174720-0.patch
	epatch "${FILESDIR}"/${P}-bug-174720-1.patch
	epatch "${FILESDIR}"/${P}-bug-214171.patch

	epatch "${FILESDIR}"/${P}-solaris.patch

	gnome2_src_prepare
}

DOCS="AUTHORS ChangeLog NEWS README"
