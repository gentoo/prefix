# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.24.3.ebuild,v 1.13 2010/10/29 20:05:13 eva Exp $

inherit gnome2 eutils

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
# Do NOT build with --disable-debug/--enable-debug=no - gnome2.eclass takes care of that
IUSE="debug doc ssl"

RDEPEND=">=dev-libs/glib-2.15.3
		 >=dev-libs/libxml2-2
		 ssl? ( >=net-libs/gnutls-1 )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9
		doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable ssl) --disable-static"
}

src_unpack() {
	gnome2_src_unpack

	# should not do any harm on other platforms, but who knows!
	# WARNING: libsoup may misbehave on interix3 regarding timeouts
	# on sockets :)
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.4.1-interix3.patch
}
