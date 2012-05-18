# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgweather/libgweather-3.4.1.ebuild,v 1.1 2012/05/06 07:26:57 tetromino Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
IUSE="+introspection doc"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"

# libsoup-gnome is to be used because libsoup[gnome] might not
# get libsoup-gnome installed by the time ${P} is built
COMMON_DEPEND=">=x11-libs/gtk+-2.90.0:3[introspection?]
	>=dev-libs/glib-2.13
	>=gnome-base/gconf-2.8
	>=net-libs/libsoup-gnome-2.25.1:2.4
	>=dev-libs/libxml2-2.6.0
	>=sys-libs/timezone-data-2010k

	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40.6
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.9 )"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-applets-2.22.0"
# eautoreconf requires >=dev-util/gtk-doc-am-1.11

pkg_setup() {
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS"
	# Do not add --disable-all-translations-in-one-xml : it will enable them
	G2CONF="${G2CONF}
		--enable-locations-compression
		--disable-static
		$(use_enable introspection)"
}
