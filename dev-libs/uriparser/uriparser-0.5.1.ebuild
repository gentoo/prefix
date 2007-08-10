# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/uriparser/uriparser-0.5.1.ebuild,v 1.1 2007/08/09 23:33:55 rbu Exp $

EAPI="prefix"

DESCRIPTION="Uriparser is a strictly RFC 3986 compliant URI parsing library in C"
HOMEPAGE="http://uriparser.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_compile() {
	econf || die "configure failed"
	emake || die "emake failed"

	if use doc; then
		ebegin "Creating documentation"
		cd "${S}/doc"
		doxygen Doxyfile
		eend 0
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog

	if use doc; then
		dohtml doc/html/*
	fi
}
