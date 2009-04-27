# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcddb/libcddb-1.3.2.ebuild,v 1.1 2009/04/26 19:45:11 patrick Exp $

EAPI="2"

DESCRIPTION="A library for accessing a CDDB server"
HOMEPAGE="http://libcddb.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc +iconv"

RESTRICT="test"

RDEPEND=""
DEPEND="doc? ( app-doc/doxygen )
	iconv? ( virtual/libiconv )"

src_configure() {
	econf --without-cdio \
		$(use_with iconv)
}

src_compile() {
	emake || die "emake failed."

	# Create API docs if needed and possible
	if use doc; then
		cd doc
		doxygen doxygen.conf || die "doxygen failed."
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO

	# Create API docs if needed and possible
	use doc && dohtml doc/html/*
}
