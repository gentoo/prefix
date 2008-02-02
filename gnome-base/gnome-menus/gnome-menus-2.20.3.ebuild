# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-menus/gnome-menus-2.20.3.ebuild,v 1.4 2008/02/01 18:50:18 ranger Exp $

EAPI="prefix"

inherit eutils gnome2 python multilib linux-info

DESCRIPTION="The GNOME menu system, implementing the F.D.O cross-desktop spec"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
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

	G2CONF="$(use_enable kernel_linux inotify) $(use_enable debug) $(use_enable python)"
}

src_unpack() {
	gnome2_src_unpack
	# Don't show KDE standalone settings desktop files in GNOME others menu
	epatch "${FILESDIR}/${PN}-2.18.3-ignore_kde_standalone.patch"
}

pkg_postinst() {
	gnome2_pkg_postinst
	use python && python_mod_optimize "${EROOT}"usr/$(get_libdir)/python*/site-packages
}

pkg_postrm() {
	gnome2_pkg_postrm
	use python && python_mod_cleanup "${EROOT}"usr/$(get_libdir)/python*/site-packages
}
