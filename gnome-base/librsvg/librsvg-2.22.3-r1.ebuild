# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/librsvg/librsvg-2.22.3-r1.ebuild,v 1.3 2009/05/03 10:48:07 nirbheek Exp $

GCONF_DEBUG="no"

inherit eutils gnome2 multilib

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="http://librsvg.sourceforge.net/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc zlib"

RDEPEND=">=media-libs/fontconfig-1.0.1
	>=media-libs/freetype-2
	>=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.15.4
	>=x11-libs/cairo-1.2
	>=x11-libs/pango-1.10
	>=dev-libs/libxml2-2.4.7
	>=dev-libs/libcroco-0.6.1
	zlib? ( >=gnome-extra/libgsf-1.6 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog README NEWS TODO"

pkg_setup() {
	# FIXME: USEify mozilla support (?)
	# croco is forced on to respect SVG specification
	G2CONF="${G2CONF}
		$(use_with zlib svgz)
		--disable-mozilla-plugin
		--with-croco
		--enable-pixbuf-loader
		--enable-gtk-theme"
}

set_gtk_confdir() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="${EROOT}etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR="${GTK2_CONFDIR:-${EPREFIX}/etc/gtk-2.0}"
}

src_unpack() {
	gnome2_src_unpack

	# gcc-4.3.2-r3 related segfault with various apps like firefox -- bug 239992
	epatch "${FILESDIR}/${P}-fix-segfault-with-firefox.patch"
}

src_install() {
	gnome2_src_install

	# remove gdk-pixbuf loaders (#47766)
	rm -fr "${ED}"/etc
}

pkg_postinst() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > "${GTK2_CONFDIR}/gdk-pixbuf.loaders"
}

pkg_postrm() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > "${GTK2_CONFDIR}/gdk-pixbuf.loaders"
}
