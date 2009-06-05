# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.20.4.ebuild,v 1.1 2009/06/03 22:25:57 eva Exp $

EAPI="2"

inherit gnome2 eutils flag-o-matic

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc glade python"

RDEPEND=">=dev-libs/glib-2.18.0
	>=x11-libs/gtk+-2.14.0
	>=x11-libs/pango-1.22.0
	sys-libs/ncurses
	glade? ( dev-util/glade:3 )
	python? ( >=dev-python/pygtk-2.4 )
	x11-libs/libX11
	x11-libs/libXft"

DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.0 )
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	sys-devel/gettext"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-deprecation
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable python)"
}

src_prepare() {
	gnome2_src_prepare

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"

	use nowheelscroll && epatch "${FILESDIR}"/${PN}-0.16.12-mouse-wheel-scroll.patch
	epatch "${FILESDIR}"/${PN}-0.20.1-interix.patch
}

src_configure() {
	local myconf=

	if [[ ${CHOST} == *-interix* ]]; then
		append-flags -D_REENTRANT
		export ac_cv_header_stropts_h=no
	fi

	[[ ${CHOST} == *-interix3* ]] && myconf="${myconf} --disable-gnome-pty-helper"

	gnome2_src_configure ${myconf}
}

pkg_preinst() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libvte.so.9
	preserve_old_lib /usr/$(get_libdir)/libvte.so.9.5.3
}

pkg_postinst() {
	gnome2_pkg_postinst
	preserve_old_lib_notify /usr/$(get_libdir)/libvte.so.9
	preserve_old_lib_notify /usr/$(get_libdir)/libvte.so.9.5.3
}
