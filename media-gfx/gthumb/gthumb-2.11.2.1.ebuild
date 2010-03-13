# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gthumb/gthumb-2.11.2.1.ebuild,v 1.2 2010/03/10 17:51:57 eva Exp $

EAPI=2
inherit autotools eutils gnome2

DESCRIPTION="Image viewer and browser for Gnome"
HOMEPAGE="http://gthumb.sourceforge.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="exif gnome-keyring gstreamer http raw tiff test"

# clutter
RDEPEND=">=dev-libs/glib-2.16:2
	>=x11-libs/gtk+-2.16:2
	>=gnome-base/gconf-2.6
	>=dev-libs/libunique-1
	media-libs/jpeg
	exif? ( >=media-gfx/exiv2-0.18 )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.28 )
	gstreamer? (
		>=media-libs/gstreamer-0.10
		>=media-libs/gst-plugins-base-0.10 )
	http? (
		>=net-libs/libsoup-2.26:2.4
		>=net-libs/libsoup-gnome-2.26:2.4 )
	tiff? ( media-libs/tiff )
	raw? ( >=media-libs/libopenraw-0.0.8 )
	!raw? ( media-gfx/dcraw )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	app-text/scrollkeeper
	>=dev-util/intltool-0.35
	app-text/gnome-doc-utils
	test? ( ~app-text/docbook-xml-dtd-4.1.2 )"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-clutter
		$(use_enable exif exiv2)
		$(use_enable gstreamer)
		$(use_enable gnome-keyring)
		$(use_enable http libsoup)
		$(use_enable raw libopenraw)
		$(use_enable test test-suite)
		$(use_enable tiff)"
}

src_prepare() {
	gnome2_src_prepare

	# Do not require unstable libunique
	epatch "${FILESDIR}/${P}-configure.patch"

	# solaris glibc has no mkdtemp so here we need a patch
	epatch "${FILESDIR}/${PN}-2.10.10-solaris.patch"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

src_install() {
	gnome2_src_install
	# gthumb does not need *.la files
	find "${ED}" -name "*.la" -delete || die "*.la files removal failed"
}
