# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/libgsf/libgsf-1.14.11.ebuild,v 1.7 2009/04/12 21:02:43 bluebird Exp $

inherit eutils gnome2 python multilib

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-solaris ~x86-solaris"
IUSE="bzip2 doc gnome python"

RDEPEND="
	>=dev-libs/glib-2.16
	>=dev-libs/libxml2-2.4.16
	gnome? ( >=gnome-base/gconf-2
		>=gnome-base/libbonobo-2
		>=gnome-base/gnome-vfs-2.2 )
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	python? ( dev-lang/python
		>=dev-python/pygobject-2.10
		>=dev-python/pygtk-2.10 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.35.0
	doc? ( >=dev-util/gtk-doc-1 )"

PDEPEND="gnome? ( media-gfx/imagemagick )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--with-gio
		--disable-static
		$(use_with bzip2 bz2)
		$(use_with gnome gnome-vfs)
		$(use_with gnome bonobo)
		$(use_with python)"
}

src_unpack() {
	gnome2_src_unpack

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

pkg_preinst() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

pkg_postinst() {
	gnome2_pkg_postinst
	if use python; then
		python_version
		python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gsf
	fi

	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.113
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.113
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gsf
}
