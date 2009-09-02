# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libspectre/libspectre-0.2.2.ebuild,v 1.4 2009/08/31 14:05:20 fauli Exp $

inherit autotools eutils

DESCRIPTION="Library to render Postscript documents."
HOMEPAGE="http://libspectre.freedesktop.org/wiki/"
SRC_URI="http://libspectre.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
SLOT="0"
IUSE="debug doc test"

RDEPEND=">=app-text/ghostscript-gpl-8.61-r1"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	test? ( x11-libs/cairo
		dev-util/pkgconfig )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.2.0-interix.patch

	eautoreconf # need new libtool for interix
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_enable debug asserts) \
		$(use_enable debug checks) \
		$(use_enable test testing) \
		|| die "econf failed"

	emake || die "emake failed"

	if use doc; then
		doxygen || die "doxygen failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc NEWS README TODO || die "installing docs failed"
	if use doc; then
		dohtml -r "${S}"/doc/html/*
	fi
}
