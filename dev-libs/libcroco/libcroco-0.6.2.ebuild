# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.2.ebuild,v 1.11 2010/10/07 22:22:57 ssuominen Exp $

EAPI=2
inherit gnome2 autotools

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="dev-libs/glib:2
	>=dev-libs/libxml2-2.4.23"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1 )
	x86-interix? ( >=dev-util/gtk-doc-1 )"

pkg_setup() {
	G2CONF="${G2CONF} --disable-static"
	DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
}

src_unpack() {
	gnome2_src_unpack

	# added gtk-doc.m4 to FILESDIR ro avoid a dependency on gtk-doc, and
	# still be able to bootstrap this.
	use x86-interix && eautoreconf # need new libtool for interix
}
