# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.4.ebuild,v 1.1 2012/02/13 10:18:53 pacho Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2 autotools

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://git.gnome.org/browse/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc test"

RDEPEND="dev-libs/glib:2
	>=dev-libs/libxml2-2.4.23"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1 )
	x86-interix? ( >=dev-util/gtk-doc-am-1 )"

pkg_setup() {
	G2CONF="${G2CONF} --disable-static"
	DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
}

src_unpack() {
	gnome2_src_unpack

	use x86-interix && eautoreconf # need new libtool for interix
}

src_prepare() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS .*\=.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi
}

src_configure() {
	econf $([[ ${CHOST} == *-darwin* ]] && echo "--disable-Bsymbolic")
}
