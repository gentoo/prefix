# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-libs/libcddb/libcddb-1.3.0-r1.ebuild,v 1.1 2007/11/13 08:38:30 aballier Exp $

EAPI="prefix"

inherit libtool autotools eutils

DESCRIPTION="A library for accessing a CDDB server"
HOMEPAGE="http://libcddb.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
RESTRICT="test"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-asneeded-nonglibc.patch"
	epatch "${FILESDIR}"/${P}-interix.patch
	eautoreconf
	elibtoolize
}

src_compile() {
	econf --without-cdio || die
	emake || die

	# Create API docs if needed and possible
	if use doc; then
		cd doc
		doxygen doxygen.conf || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	# Create API docs if needed and possible
	use doc && dohtml doc/html/*
}
