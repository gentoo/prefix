# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.30.2-r1.ebuild,v 1.5 2010/08/01 11:09:51 fauli Exp $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI}
	mirror://gentoo/${PN}-2.30.1-build-gir-patches.tar.bz2"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
# Do NOT build with --disable-debug/--enable-debug=no - gnome2.eclass takes care of that
IUSE="debug doc +introspection gnome ssl"

RDEPEND=">=dev-libs/glib-2.21.3
	>=dev-libs/libxml2-2
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	ssl? ( >=net-libs/gnutls-2.1.7 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1 )"
#	test? (
#		www-servers/apache
#		dev-lang/php
#		net-misc/curl )
PDEPEND="gnome? ( ~net-libs/${PN}-gnome-${PV} )"

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

	# Fix test to follow POSIX (for x86-fbsd)
	# No patch to prevent having to eautoreconf
	sed -e 's/\(test.*\)==/\1=/g' -i configure.ac configure || die "sed failed"

	# Patch *must* be applied conditionally (see patch for details)
	if use doc; then
		# Fix bug 268592 (build fails !gnome && doc)
		epatch "${FILESDIR}/${PN}-2.30.1-fix-build-without-gnome-with-doc.patch"
	fi

	if use introspection; then
		epatch "${WORKDIR}/${PN}-2.30.1-build-gir-1.patch"
		epatch "${WORKDIR}/${PN}-2.30.1-build-gir-2.patch"
	fi

	# should not do any harm on other platforms, but who knows!
	# WARNING: libsoup may misbehave on interix3 regarding timeouts
	# on sockets :)
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.4.1-interix3.patch
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${P}-interix5.patch

	# Fix for new versions of gnutls (bug #307343, GNOME bug #22857)
	epatch "${FILESDIR}/${P}-disable-tls1.2.patch"

	eautoreconf
}
