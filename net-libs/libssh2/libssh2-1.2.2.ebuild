# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh2/libssh2-1.2.2.ebuild,v 1.2 2009/12/14 19:14:29 pva Exp $

EAPI="2"

inherit eutils

DESCRIPTION="Library implementing the SSH2 protocol"
HOMEPAGE="http://www.libssh2.org/"
SRC_URI="http://www.${PN}.org/download/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~sparc64-solaris"
IUSE="gcrypt zlib"

DEPEND="!gcrypt? ( dev-libs/openssl )
	gcrypt? ( dev-libs/libgcrypt )
	zlib? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.2.1-irix.patch
}

src_configure() {
	local myconf

	if use gcrypt; then
		myconf="--with-libgcrypt"
	else
		myconf="--with-openssl"
	fi

	econf \
		$(use_with zlib libz) \
		${myconf}
}

src_test() {
	if [[ ${EUID} -ne 0 ]]; then #286741
		ewarn "Some tests require real user that is allowed to login."
		ewarn "ssh2.sh test disabled."
		sed -e 's:ssh2.sh::' -i tests/Makefile
	fi
	emake check || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README
}
