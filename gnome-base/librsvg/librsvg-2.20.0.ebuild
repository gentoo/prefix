# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/librsvg/librsvg-2.20.0.ebuild,v 1.8 2008/04/20 01:35:57 vapier Exp $

inherit gnome2 multilib

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="http://librsvg.sourceforge.net/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="doc gnome zlib"

RDEPEND="
	>=media-libs/fontconfig-1.0.1
	>=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.12
	>=dev-libs/libxml2-2.4.7
	>=x11-libs/cairo-1.2
	>=x11-libs/pango-1.2
	>=media-libs/freetype-2
	zlib? ( >=gnome-extra/libgsf-1.6 )
	>=dev-libs/libcroco-0.6.1
	gnome? (
		>=gnome-base/gnome-vfs-2
		>=gnome-base/libgnomeprint-2.2
		>=gnome-base/libgnomeprintui-2.2
	)"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog README NEWS TODO"

pkg_setup() {
	# FIXME: USEify croco support (?)
	G2CONF="${G2CONF}
		$(use_with zlib svgz)
		$(use_enable gnome gnome-vfs)
		$(use_enable gnome gnome-print)
		--disable-mozilla-plugin
		--with-croco
		--enable-pixbuf-loader
		--enable-gtk-theme"
}

set_gtk_confdir() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0}
}

src_install() {
	gnome2_src_install

	# remove gdk-pixbuf loaders (#47766)
	rm -fr "${ED}"/etc
}

pkg_postinst() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > ${GTK2_CONFDIR}/gdk-pixbuf.loaders
}

pkg_postrm() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > ${GTK2_CONFDIR}/gdk-pixbuf.loaders
}
