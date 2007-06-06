# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/librsvg/librsvg-2.16.1-r1.ebuild,v 1.8 2007/06/02 02:54:26 ranger Exp $

EAPI="prefix"

inherit multilib gnome2 eutils

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="http://librsvg.sourceforge.net/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc gnome zlib"

RDEPEND=">=media-libs/fontconfig-1.0.1
	>=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.12
	>=dev-libs/libxml2-2.4.7
	>=x11-libs/cairo-1.2
	>=x11-libs/pango-1.2
	>=dev-libs/libcroco-0.6.1
	>=media-libs/freetype-2
	gnome? ( >=gnome-base/gnome-vfs-2 )
	zlib? ( >=gnome-extra/libgsf-1.6 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-0.9 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

set_gtk_confdir() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0}
}

pkg_setup() {
	G2CONF="--enable-gtk-theme --enable-pixbuf-loader \
			--disable-mozilla-plugin --with-croco \
			--disable-gnome-print \
			$(use_enable gnome gnome-vfs) \
			$(use_with zlib svgz)"
}

src_unpack() {
	gnome2_src_unpack

	# Still fails even with disable-gtk-doc
	if ! use doc; then
		epatch ${FILESDIR}/${PN}-2.15.90-die-gtk-doc-die.patch
	fi

	# Patch from truedfx to prevent floating point exceptions
	epatch ${FILESDIR}/${PN}-2.16.1-uninit.patch

	cp /usr/share/libtool/install-sh .
}

src_install() {
	gnome2_src_install plugindir=/usr/$(get_libdir)/nsbrowser/plugins/

	# remove gdk-pixbuf loaders (#47766)
	rm -fr ${ED}/etc

	# remove plugins dir since we disable the plugin
	rm -fr ${ED}/usr/lib/nsbrowser
}

pkg_postinst() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > ${GTK2_CONFDIR}/gdk-pixbuf.loaders
}

pkg_postrm() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > ${GTK2_CONFDIR}/gdk-pixbuf.loaders
}
