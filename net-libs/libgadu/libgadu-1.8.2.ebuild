# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libgadu/libgadu-1.8.2.ebuild,v 1.8 2009/03/20 15:43:51 ranger Exp $

inherit eutils libtool

DESCRIPTION="This library implements the client side of the Gadu-Gadu protocol"
HOMEPAGE="http://toxygen.net/libgadu/"
SRC_URI="http://toxygen.net/libgadu/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

IUSE="ssl threads"

DEPEND="ssl? ( >=dev-libs/openssl-0.9.6m )"
RDEPEND="${DEPEND}
	!=net-im/kadu-0.6.0.2
	!=net-im/kadu-0.6.0.1"

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
