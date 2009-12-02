# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmemcached/libmemcached-0.35.ebuild,v 1.1 2009/11/24 06:24:22 robbat2 Exp $

EAPI=2

inherit eutils

DESCRIPTION="a C client library to the memcached server"
HOMEPAGE="http://tangent.org/552/libmemcached.html"
SRC_URI="http://download.tangent.org/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug hsieh"

DEPEND="net-misc/memcached"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.28-runtestsasuser.patch"
}

src_configure() {
	econf \
		$(use_with debug debug) \
		$(use_enable hsieh hsieh_hash)
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

src_test() {
	cd tests || die "Tests failed"
	emake testapp testplus library_test || die "Tests failed"
}
