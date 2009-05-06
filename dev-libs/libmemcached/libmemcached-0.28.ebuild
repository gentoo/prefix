# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmemcached/libmemcached-0.28.ebuild,v 1.2 2009/05/05 23:35:42 mr_bones_ Exp $

inherit eutils

DESCRIPTION="a C client library to the memcached server"
HOMEPAGE="http://tangent.org/552/libmemcached.html"
SRC_URI="http://download.tangent.org/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"

DEPEND="net-misc/memcached"
RDEPEND="${DEPEND}"

#RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.28-runtestsasuser.patch
	epatch "${FILESDIR}"/${PN}-0.28-removebogustest.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

src_test() {
	vecho ">>> Test phase [test]: ${CATEGORY}/${PF}"
	emake test || die "tests failed"
	vecho ">>> Test phase [none]: ${CATEGORY}/${PF}"
}
