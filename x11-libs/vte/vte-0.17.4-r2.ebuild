# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.17.4-r2.ebuild,v 1.2 2009/01/05 13:29:29 remi Exp $

inherit gnome2 eutils flag-o-matic

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
# pcre is broken in this release
IUSE="debug doc python opengl nowheelscroll"

RDEPEND=">=dev-libs/glib-2.14
	>=x11-libs/gtk+-2.6
	>=x11-libs/pango-1.1
	>=media-libs/freetype-2.0.2
	media-libs/fontconfig
	sys-libs/ncurses
	opengl? (
		virtual/opengl
		virtual/glu
	)
	python? (
		>=dev-python/pygtk-2.4
		>=dev-lang/python-2.4.4-r5
	)
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
		$(use_enable debug)
		$(use_enable python)
		$(use_with opengl glX)
		--with-xft2 --with-pangox"
}

src_compile() {
	local myconf=

	if [[ ${CHOST} == *-interix* ]]; then
		append-flags -D_REENTRANT
		export ac_cv_header_stropts_h=no
	fi

	[[ ${CHOST} == *-interix3* ]] && myconf="${myconf} --disable-gnome-pty-helper"

	gnome2_src_compile ${myconf}
}

src_unpack() {
	gnome2_src_unpack
	epatch "${FILESDIR}/${P}-fix-highlighting-on-activity.patch"

	use nowheelscroll && epatch "${FILESDIR}"/${PN}-0.16.12-mouse-wheel-scroll.patch
	epatch "${FILESDIR}"/${PN}-0.16.13-interix.patch
}
