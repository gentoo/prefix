# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/yelp/yelp-2.26.0.ebuild,v 1.2 2009/05/31 18:54:43 eva Exp $

EAPI=1

inherit autotools eutils gnome2

DESCRIPTION="Help browser for GNOME"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="beagle lzma"

RDEPEND=">=gnome-base/gconf-2
	>=app-text/gnome-doc-utils-0.15.2
	>=x11-libs/gtk+-2.10
	>=dev-libs/glib-2.16
	>=gnome-base/libglade-2
	>=gnome-base/libgnome-2.14
	>=gnome-base/libgnomeui-2.14
	>=dev-libs/libxml2-2.6.5
	>=dev-libs/libxslt-1.1.4
	>=x11-libs/startup-notification-0.8
	>=dev-libs/dbus-glib-0.71
	beagle? ( || (
		>=dev-libs/libbeagle-0.3.0
		=app-misc/beagle-0.2* ) )
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
# If eautoreconf:
#	gnome-base/gnome-common

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	# Fix automagic lzma support, bug #266128
	epatch "${FILESDIR}/${P}-automagic-lzma.patch"

	eautoreconf

	# strip stupid options in configure, see bug #196621
	sed -i 's|$AM_CFLAGS -pedantic -ansi|$AM_CFLAGS|' configure || die "sed	failed"
}

pkg_setup() {
	G2CONF="${G2CONF}
		--with-gecko=libxul-embedding
		$(use_enable lzma)"

	if use beagle; then
		G2CONF="${G2CONF} --with-search=beagle"
	else
		G2CONF="${G2CONF} --with-search=basic"
	fi
}
