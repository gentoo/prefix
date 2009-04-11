# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/yelp/yelp-2.22.1-r11.ebuild,v 1.4 2009/01/08 16:53:50 armin76 Exp $

EAPI=1

inherit eutils autotools gnome2

DESCRIPTION="Help browser for GNOME"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="beagle lzma"

RDEPEND=">=gnome-base/gconf-2
	>=app-text/gnome-doc-utils-0.11.1
	>=x11-libs/gtk+-2.10
	>=gnome-base/gnome-vfs-2
	>=gnome-base/libglade-2
	>=gnome-base/libgnome-2.14
	>=gnome-base/libgnomeui-2.14
	>=dev-libs/libxml2-2.6.5
	>=dev-libs/libxslt-1.1.4
	>=x11-libs/startup-notification-0.8
	>=dev-libs/glib-2
	>=dev-libs/dbus-glib-0.71
	beagle? ( || ( >=dev-libs/libbeagle-0.3.0 =app-misc/beagle-0.2* ) )
	net-libs/xulrunner:1.9
	sys-libs/zlib
	app-arch/bzip2
	lzma? ( app-arch/lzma-utils )
	>=app-text/rarian-0.7
	>=app-text/scrollkeeper-9999"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	gnome-base/gnome-common"

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	# patch to work with >=libbeagle-0.3, bug #215026
	epatch "${FILESDIR}"/yelp-2.22-with-beagle-0.3.patch

	# Patch format string.  Bug #234079
	epatch "${FILESDIR}"/yelp-2.22.1-format-string.patch

	# Use xulrunner 1.9.  Bug #204632
	epatch "${FILESDIR}"/${P}-xulrunner-1.9.patch

	# patch to fix parallel make, see bug #217250
	sed -e "s/install-exec-local:/install-exec-hook:/" -i src/Makefile.am

	intltoolize --force --automake || die "intltoolize failed"
	eautoreconf

	# strip stupid options in configure, see bug #196621
	sed -i 's|$AM_CFLAGS -pedantic -ansi|$AM_CFLAGS|' configure
}

pkg_setup() {
	# FIXME: Add patch to make lzma-utils not automagic and use_enable here
	G2CONF="${G2CONF} --with-gecko=libxul"

	if use beagle; then
		G2CONF="${G2CONF} --with-search=beagle"
	else
		G2CONF="${G2CONF} --with-search=basic"
	fi
}
