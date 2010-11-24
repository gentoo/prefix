# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.32.0.ebuild,v 1.2 2010/10/24 13:43:42 pacho Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit autotools eutils gnome2

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc +introspection ssl test"

RDEPEND=">=dev-libs/glib-2.21.3
	>=dev-libs/libxml2-2
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	ssl? ( >=net-libs/gnutls-2.1.7 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/gtk-doc-am-1.10
	doc? ( >=dev-util/gtk-doc-1.10 )"
#	test? (
#		www-servers/apache
#		dev-lang/php
#		net-misc/curl )

DOCS="AUTHORS NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		--without-gnome
		$(use_enable introspection)
		$(use_enable ssl)"
}

src_configure() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	addpredict /usr/share/snmp/mibs/.index
	gnome2_src_configure
}

src_prepare() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests (bug #226271)
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

	# Patch *must* be applied conditionally (see patch for details)
	if use doc; then
		# Fix bug 268592 (build fails without gnome && doc)
		epatch "${FILESDIR}/${PN}-2.30.1-fix-build-without-gnome-with-doc.patch"
		eautoreconf
	fi

	# should not do any harm on other platforms, but who knows!
	# WARNING: libsoup may misbehave on interix3 regarding timeouts
	# on sockets :)
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.4.1-interix3.patch
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${PN}-2.30.2-interix5.patch
}
