# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libspiff/libspiff-1.0.0.ebuild,v 1.2 2008/10/28 02:07:53 mr_bones_ Exp $

inherit eutils

DESCRIPTION="Library for XSPF playlist reading and writing"
HOMEPAGE="http://libspiff.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="BSD LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/expat-1.95.8
	>=dev-libs/uriparser-0.7.2"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-testincludes.patch"
}

src_compile() {
	econf --disable-dependency-tracking
	emake || die "emake failed."

	if use doc; then
		cd "${S}/doc"
		doxygen Doxyfile || die "doxygen failed."
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README THANKS

	if use doc; then
		dohtml doc/html/*
	fi
}
