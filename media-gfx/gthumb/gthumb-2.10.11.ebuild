# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gthumb/gthumb-2.10.11.ebuild,v 1.7 2010/05/15 17:05:22 armin76 Exp $

EAPI=2

inherit eutils gnome2

DESCRIPTION="Image viewer and browser for Gnome"
HOMEPAGE="http://gthumb.sourceforge.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+gphoto2 iptc raw tiff test"

RDEPEND=">=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.10:2
	>=dev-libs/libxml2-2.4
	>=gnome-base/libgnome-2.6
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/libgnomecanvas-2.6
	>=gnome-base/gnome-vfs-2.6
	>=gnome-base/libglade-2.4
	>=media-libs/libexif-0.6.13
	gphoto2? ( >=media-libs/libgphoto2-2.1.3 )
	iptc? ( >=media-libs/libiptcdata-0.2.1 )
	>=gnome-base/libbonobo-2.6
	>=gnome-base/libbonoboui-2.6
	>=gnome-base/gconf-2.6
	media-libs/jpeg
	tiff? ( media-libs/tiff )
	raw? ( media-libs/libopenraw )
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXext
	x11-libs/libXxf86vm"
DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xextproto
	dev-util/pkgconfig
	app-text/scrollkeeper
	>=dev-util/intltool-0.29
	app-text/gnome-doc-utils
	test? ( ~app-text/docbook-xml-dtd-4.1.2 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack
	# solaris glibc has no mkdtemp so here we need a patch
	epatch "${FILESDIR}/${PN}-2.10.10-solaris.patch"
}

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable gphoto2)
		$(use_enable raw libopenraw)
		$(use_enable iptc iptcdata)
		$(use_enable tiff)"
}

src_prepare() {
	# Fix tests
	echo "data/gthumb-import.desktop.in" >> po/POTFILES.in
}
