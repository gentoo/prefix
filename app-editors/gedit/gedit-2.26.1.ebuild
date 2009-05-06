# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gedit/gedit-2.26.1.ebuild,v 1.1 2009/05/05 11:37:41 nirbheek Exp $

GCONF_DEBUG="no"

inherit gnome2 python

DESCRIPTION="A text editor for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc python spell xattr"

RDEPEND=">=gnome-base/gconf-2
	xattr? ( sys-apps/attr )
	>=x11-libs/libSM-1.0
	>=dev-libs/libxml2-2.5.0
	>=dev-libs/glib-2.18
	>=x11-libs/gtk+-2.15
	>=x11-libs/gtksourceview-2.5
	spell? (
		>=app-text/enchant-1.2
		>=app-text/iso-codes-0.35
	)
	python? (
		>=dev-python/pygobject-2.15.4
		>=dev-python/pygtk-2.12
		>=dev-python/pygtksourceview-2.2
	)"

DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	>=app-text/scrollkeeper-0.3.11
	>=app-text/gnome-doc-utils-0.3.2
	~app-text/docbook-xml-dtd-4.1.2
	doc? ( >=dev-util/gtk-doc-1 )"
# gnome-common and gtk-doc-am needed to eautoreconf

DOCS="AUTHORS BUGS ChangeLog MAINTAINERS NEWS README"

if [[ "${ARCH}" == "PPC" ]] ; then
	# HACK HACK HACK: someone fix this garbage
	MAKEOPTS="${MAKEOPTS} -j1"
fi

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-scrollkeeper
		$(use_enable python)
		$(use_enable spell)
		$(use_enable xattr attr)"
}

src_unpack() {
	gnome2_src_unpack

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

pkg_postinst() {
	use python && python_mod_optimize /usr/$(get_libdir)/gedit-2/plugins
}

pkg_postrm() {
	use python && python_mod_cleanup /usr/$(get_libdir)/gedit-2/plugins
}
