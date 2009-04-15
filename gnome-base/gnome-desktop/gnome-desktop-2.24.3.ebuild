# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.24.3.ebuild,v 1.7 2009/04/12 20:52:11 bluebird Exp $

inherit eutils gnome2

DESCRIPTION="Libraries for the gnome desktop that are not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc"

# FIXME: Python deps are needed for gnome-about but not
# listed in configure.ac
RDEPEND=">=dev-libs/libxml2-2.4.20
	>=x11-libs/gtk+-2.11.3
	>=dev-libs/glib-2.15.4
	>=x11-libs/libXrandr-1.2
	>=gnome-base/gconf-2
	>=gnome-base/libgnomeui-2.6
	>=x11-libs/startup-notification-0.5
	>=dev-python/pygtk-2.8
	>=dev-python/pygobject-2.14
	>=dev-python/libgnome-python-2.22"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	>=app-text/gnome-doc-utils-0.3.2
	doc? ( >=dev-util/gtk-doc-1.4 )
	~app-text/docbook-xml-dtd-4.1.2
	x11-proto/xproto
	>=x11-proto/randrproto-1.2"
# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto
# Includes X11/extensions/Xrandr.h that includes randr.h from randrproto (and
# eventually libXrandr shouldn't RDEPEND on randrproto)

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} --with-gnome-distributor=Gentoo --disable-scrollkeeper"
}

src_unpack() {
	gnome2_src_unpack

	# Do not load background if not needed, bug #251350
	epatch "${FILESDIR}/${PN}-2.24.2-background.patch"
}

pkg_postinst() {
	ewarn
	ewarn "If you are upgrading from <gnome-base/gnome-desktop-2.24, please"
	ewarn "make sure you run revdep-rebuild at the end of the upgrade."
}
