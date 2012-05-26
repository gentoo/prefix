# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.28.2-r301.ebuild,v 1.2 2012/05/05 03:52:26 jdhore Exp $

EAPI="3"
GCONF_DEBUG="yes"
GNOME_TARBALL_SUFFIX="xz"
GNOME2_LA_PUNT="yes"

inherit autotools eutils gnome2

DESCRIPTION="GNOME terminal widget"
HOMEPAGE="http://git.gnome.org/browse/vte"
SRC_URI="${SRC_URI} mirror://gentoo/introspection.m4.bz2"

LICENSE="LGPL-2"
SLOT="2.90"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc glade +introspection"

PDEPEND="x11-libs/gnome-pty-helper"
RDEPEND=">=dev-libs/glib-2.26:2
	>=x11-libs/gtk+-3.0:3[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXft

	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.13 )"

pkg_setup() {
	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	# Do not disable gnome-pty-helper, bug #401389
	G2CONF="${G2CONF}
		--disable-deprecation
		--disable-maintainer-mode
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)
		--with-gtk=3.0"

	if [[ ${CHOST} == *-interix* ]]; then
		G2CONF="${G2CONF} --disable-Bsymbolic"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	DOCS="AUTHORS ChangeLog HACKING NEWS README"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.28.0-fix-gdk-targets.patch"
	# https://bugzilla.gnome.org/show_bug.cgi?id=652290
	epatch "${FILESDIR}"/${PN}-0.26.2-interix.patch

	mv "${WORKDIR}/introspection.m4" "${S}/" || die
	AT_M4DIR="." eautoreconf

	gnome2_src_prepare
}

src_install() {
	gnome2_src_install
	rm -v "${ED}usr/libexec/gnome-pty-helper" || die
}
