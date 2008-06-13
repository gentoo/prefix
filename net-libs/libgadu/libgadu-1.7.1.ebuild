# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libgadu/libgadu-1.7.1.ebuild,v 1.7 2007/05/21 19:59:59 dertobi123 Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="This library implements the client side of the Gadu-Gadu protocol"
HOMEPAGE="http://toxygen.net/libgadu/"
SRC_URI="http://toxygen.net/libgadu/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

IUSE="ssl threads"

DEPEND="ssl? ( >=dev-libs/openssl-0.9.6m )"

src_compile() {
	econf \
	    --enable-shared \
	    `use_with threads pthread` \
	    `use_with ssl openssl` \
	     || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	einstall || die
}
