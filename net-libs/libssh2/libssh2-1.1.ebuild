# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh2/libssh2-1.1.ebuild,v 1.1 2009/04/18 15:25:55 patrick Exp $

EAPI="2"

DESCRIPTION="Library implementing the SSH2 protocol"
HOMEPAGE="http://www.libssh2.org/"
SRC_URI="mirror://sourceforge/libssh2/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc64-solaris"
IUSE="libgcrypt zlib"

DEPEND="!libgcrypt? ( dev-libs/openssl )
	libgcrypt? ( dev-libs/libgcrypt )
	zlib? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"

src_configure() {
	local myconf

	if use libgcrypt ; then
		myconf="--with-libgcrypt"
	else
		myconf="--with-openssl"
	fi

	econf \
		$(use_with zlib libz) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README
}
