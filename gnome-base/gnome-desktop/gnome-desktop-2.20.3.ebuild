# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.20.3.ebuild,v 1.9 2008/07/01 20:58:30 eva Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Libraries for the gnome desktop that is not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=dev-libs/libxml2-2.4.20
	>=x11-libs/gtk+-2.11.3
	>=dev-libs/glib-2.13.0
	>=gnome-base/gconf-2
	>=gnome-base/libgnomecanvas-2
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/gnome-vfs-2
	>=x11-libs/startup-notification-0.5
	!gnome-base/gnome-core"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	>=app-text/gnome-doc-utils-0.3.2
	~app-text/docbook-xml-dtd-4.1.2
	doc? ( >=dev-util/gtk-doc-1.4 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} --with-gnome-distributor=Gentoo --disable-scrollkeeper"
}

src_unpack() {
	gnome2_src_unpack

	# Fix bug 16853 by building gnome-about with IEEE to prevent
	# floating point exceptions on alpha
	if use alpha; then
		sed -i '/^CFLAGS/s/$/ -mieee/' "${S}"/gnome-about/Makefile.in \
		|| die "sed failed (2)"
	fi
}
