# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gtkhtml/gtkhtml-3.26.1.1.ebuild,v 1.1 2009/05/03 21:58:10 eva Exp $

EAPI=1

inherit gnome2

DESCRIPTION="Lightweight HTML Rendering/Printing/Editing Engine"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="3.14"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="glade"

# We keep bonobo until we can make sure no apps in tree uses
# the old composer code.
# We could probably enable the glade catalog installation with
# USE="glade" if someone requests it
RDEPEND=">=x11-libs/gtk+-2.14
	>=gnome-base/gail-1.1
	>=x11-themes/gnome-icon-theme-2.22.0
	>=gnome-base/libbonobo-2.20.3
	>=gnome-base/libbonoboui-2.2.4
	>=gnome-base/orbit-2
	>=gnome-base/libglade-2
	>=gnome-base/libgnomeui-2
	app-text/enchant
	gnome-base/gconf:2
	>=app-text/iso-codes-0.49
	net-libs/libsoup:2.4
	glade? ( dev-util/glade:3 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.40.0
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"

pkg_setup() {
	ELTCONF="--reverse-deps"
	G2CONF="${G2CONF}
		--disable-static
		--with-bonobo-editor
		$(use_with glade glade-catalog)"
}

src_unpack() {
	gnome2_src_unpack

	# Fix deprecated API disabling in used glib library - this is not future-proof, bug 210657
	sed -i -e '/G_DISABLE_DEPRECATED/d' \
		"${S}/gtkhtml/Makefile.am" "${S}/gtkhtml/Makefile.in" \
		"${S}/components/html-editor/Makefile.am" \
		"${S}/components/html-editor/Makefile.in" \
		|| die "sed 1 failed"

	sed -i -e 's:-DGTK_DISABLE_DEPRECATED=1 -DGDK_DISABLE_DEPRECATED=1 -DG_DISABLE_DEPRECATED=1 -DGNOME_DISABLE_DEPRECATED=1::g' \
		"${S}/a11y/Makefile.am" "${S}/a11y/Makefile.in" || die "sed 2 failed"

	cp "${FILESDIR}/gtkhtml-editor.xml" "${S}/components/editor/"
}
