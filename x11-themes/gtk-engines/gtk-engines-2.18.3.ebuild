# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.18.3.ebuild,v 1.1 2009/09/23 09:23:09 mrpouet Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools eutils gnome2

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="accessibility lua"

RDEPEND=">=x11-libs/gtk+-2.12
	lua? ( dev-lang/lua )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.31
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} --enable-animation $(use_enable lua) $(use_with lua system-lua)"
	use accessibility || G2CONF="${G2CONF} --disable-hc"
}
src_prepare() {
	gnome2_src_prepare
	# Fix typo in AM_CONDITIONNAL for system lua feature,
	# upstream bug #594014.
	epatch "${FILESDIR}"/${P}-fix-system-lua-check.patch
	intltoolize --automake --copy --force || die "intltoolize failed"
	eautoreconf
}
