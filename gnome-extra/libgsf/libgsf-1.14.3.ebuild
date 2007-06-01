# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/libgsf/libgsf-1.14.3.ebuild,v 1.8 2007/05/31 16:22:52 jer Exp $

EAPI="prefix"

inherit eutils gnome2

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="bzip2 doc gnome python"

RDEPEND=">=dev-libs/libxml2-2.4.16
	>=dev-libs/glib-2.6
	sys-libs/zlib
	gnome? ( media-gfx/imagemagick
		>=gnome-base/gconf-2
		>=gnome-base/libbonobo-2
		>=gnome-base/gnome-vfs-2.2 )
	bzip2? ( app-arch/bzip2 )
	python? ( dev-lang/python
		>=dev-python/pygtk-2.8 )"
# This package (currently) needs >=pygobject-2.8 and pygtk-codegen-2.0 for python
# support, which is provided by either pygtk-2.8* or any pygobject version (they were
# separated for pygobject version 2.10 and up). As for codegen we already need
# pygtk, then depending on just >=pygtk-2.8 is sufficient, as 2.8 provides pygobject
# and 2.10 will pull in the pygobject separate package.

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.29
	doc? ( >=dev-util/gtk-doc-1 )"

G2CONF="${G2CONF} \
	$(use_with bzip2 bz2) \
	$(use_with gnome) \
	$(use_with python)"

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

pkg_postinst() {
	gnome2_pkg_postinst

	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"
