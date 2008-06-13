# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.4.0.ebuild,v 1.1 2008/03/12 20:20:19 leio Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="doc ssl"

RDEPEND=">=dev-libs/glib-2.15.3
		 >=dev-libs/libxml2-2
		 ssl? ( >=net-libs/gnutls-1 )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9
		doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="$(use_enable ssl)"
}
