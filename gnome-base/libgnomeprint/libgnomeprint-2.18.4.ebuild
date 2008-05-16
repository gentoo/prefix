# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/gnome-base/libgnomeprint/libgnomeprint-2.18.4.ebuild,v 1.8 2008/04/20 01:35:59 vapier Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Printer handling for Gnome"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2.2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="cups doc"

RDEPEND=">=dev-libs/glib-2
	>=media-libs/libart_lgpl-2.3.7
	>=x11-libs/pango-1.5
	>=dev-libs/libxml2-2.4.23
	>=media-libs/fontconfig-1
	>=media-libs/freetype-2.0.5
	sys-libs/zlib
	cups? (
		>=net-print/cups-1.1.20
		>=net-print/libgnomecups-0.2 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	sys-devel/flex
	sys-devel/bison
	doc? (
		~app-text/docbook-xml-dtd-4.1.2
		>=dev-util/gtk-doc-0.9 )"

DOCS="AUTHORS BUGS ChangeLog* NEWS README"
USE_DESTDIR="1"

pkg_setup() {
	G2CONF="$(use_with cups)"
}
