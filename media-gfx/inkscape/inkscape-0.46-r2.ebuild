# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-gfx/inkscape/inkscape-0.46-r2.ebuild,v 1.2 2008/04/06 13:53:05 maekke Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="dia doc gnome inkjar jabber lcms mmx perl postscript spell wmf"
RESTRICT="test"

COMMON_DEPEND="
	app-text/poppler-bindings
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
	virtual/xft
	>=x11-libs/gtk+-2.10.7
	>=x11-libs/pango-1.4.0
	gnome? (
		>=gnome-base/gnome-vfs-2.0
		gnome-base/libgnomeprint
		gnome-base/libgnomeprintui
	)
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
	postscript? ( >=media-gfx/pstoedit-3.44 media-gfx/skencil )
	wmf? ( media-libs/libwmf )"

DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	dev-util/pkgconfig
	x11-libs/libX11
	>=dev-util/intltool-0.29"

pkg_setup() {
	# bug 207070
	if use postscript && ! built_with_use media-gfx/pstoedit plotutils ; then
		eerror "you need to emerge media-gfx/pstoedit with plotutils support."
		die "remerge media-gfx/pstoedit with USE=\"plotutils\""
	fi
	# bug 213026 and bug 213706
	if ! built_with_use app-text/poppler-bindings cairo ; then
		eerror "you need to emerge app-text/poppler-bindings with cairo	support."
		die "remerge app-text/poppler-bindings with USE=\"cairo\""
	fi

	G2CONF="${G2CONF} --with-xft"
	G2CONF="${G2CONF} $(use_with spell gtkspell)"
	G2CONF="${G2CONF} $(use_enable jabber inkboard)"
	G2CONF="${G2CONF} $(use_enable mmx)"
	G2CONF="${G2CONF} $(use_with inkjar)"
	G2CONF="${G2CONF} $(use_with gnome gnome-vfs)"
	G2CONF="${G2CONF} $(use_with gnome gnome-print)"
	G2CONF="${G2CONF} $(use_enable lcms)"
	G2CONF="${G2CONF} $(use_with perl)"
}

src_unpack() {
	gnome2_src_unpack

	cd "${S}"
	epatch "${FILESDIR}"/${P}-gcc43.patch
}

DOCS="AUTHORS ChangeLog NEWS README"
