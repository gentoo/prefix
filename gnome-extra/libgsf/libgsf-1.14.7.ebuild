# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/libgsf/libgsf-1.14.7.ebuild,v 1.7 2007/11/27 03:49:37 jer Exp $

EAPI="prefix"

inherit eutils gnome2 python multilib

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="bzip2 doc gnome python"

RDEPEND="
	>=dev-libs/glib-2.8
	>=dev-libs/libxml2-2.4.16
	gnome? ( media-gfx/imagemagick
		>=gnome-base/gconf-2
		>=gnome-base/libbonobo-2
		>=gnome-base/gnome-vfs-2.2 )
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	python? ( dev-lang/python
		>=dev-python/pygobject-2.10 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.29
	doc? ( >=dev-util/gtk-doc-1 )"

G2CONF="${G2CONF} \
	$(use_with bzip2 bz2) \
	$(use_with gnome) \
	$(use_with python)"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

pkg_postinst() {
	gnome2_pkg_postinst
	use python && python_mod_optimize /usr/$(get_libdir)/python*/site-packages/gsf

	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

pkg_postrm() {
	gnome2_pkg_postrm
	use python && python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gsf
}
