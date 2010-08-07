# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-menus/gnome-menus-2.20.3.ebuild,v 1.12 2010/06/23 14:55:34 arfrever Exp $

inherit eutils gnome2 python linux-info

DESCRIPTION="The GNOME menu system, implementing the F.D.O cross-desktop spec"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug python kernel_linux"

RDEPEND=">=dev-libs/glib-2.6
	python? (
		>=dev-lang/python-2.4.4-r5
		dev-python/pygtk
	)"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	if use !prefix && use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY"
		linux-info_pkg_setup
	fi

	G2CONF="${G2CONF}
		$(use_enable kernel_linux inotify)
		$(use_enable debug)
		$(use_enable python)"
}

src_unpack() {
	gnome2_src_unpack

	# Don't show KDE standalone settings desktop files in GNOME others menu
	epatch "${FILESDIR}/${PN}-2.18.3-ignore_kde_standalone.patch"

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

pkg_postinst() {
	gnome2_pkg_postinst
	if use python; then
		python_mod_optimize $(python_get_sitedir)/GMenuSimpleEditor
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm
	if use python; then
		python_mod_cleanup $(python_get_sitedir)/GMenuSimpleEditor
	fi
}
