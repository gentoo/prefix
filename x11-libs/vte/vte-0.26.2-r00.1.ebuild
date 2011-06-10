# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.26.2.ebuild,v 1.10 2011/04/10 09:07:41 ssuominen Exp $

EAPI="3"
GCONF_DEBUG="yes"
PYTHON_DEPEND="python? 2:2.4"

inherit gnome2 python autotools eutils

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc glade +introspection python"

RDEPEND=">=dev-libs/glib-2.22:2
	>=x11-libs/gtk+-2.20:2
	>=x11-libs/pango-1.22.0
	sys-libs/ncurses
	glade? ( dev-util/glade:3 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	python? ( >=dev-python/pygtk-2.4 )
	x11-libs/libX11
	x11-libs/libXft"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.13 )
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	sys-devel/gettext"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		--disable-deprecation
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)
		$(use_enable python)
		--with-html-dir=${EPREFIX}/usr/share/doc/${PF}/html
		--with-gtk=2.0"

	if [[ ${CHOST} == *-interix* ]]; then
		G2CONF="${G2CONF} 
			--disable-Bsymbolic
			--disable-gnome-pty-helper"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	DOCS="AUTHORS ChangeLog HACKING NEWS README"
	use python && python_set_active_version 2
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-interix.patch

	eautoreconf || die
	gnome2_src_prepare
}

src_install() {
	gnome2_src_install
	find "${ED}" -name '*.la' -exec rm -f {} +
	use python && python_clean_installation_image
}
