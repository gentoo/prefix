# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-gfx/gthumb/gthumb-2.10.8.ebuild,v 1.6 2008/04/03 14:18:56 ranger Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Image viewer and browser for Gnome"
HOMEPAGE="http://gthumb.sourceforge.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="gphoto2 iptc raw tiff"

# Unknown item missing from deps, gtkunique.
RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.10
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
	raw? ( media-libs/libopenraw )"
DEPEND="${RDEPEND}
	x11-proto/inputproto
	>=dev-util/pkgconfig-0.9.0
	app-text/scrollkeeper
	>=dev-util/intltool-0.29
	app-text/gnome-doc-utils"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable gphoto2) $(use_enable raw libopenraw)
		$(use_enable iptc iptcdata) $(use_enable tiff)"
}
