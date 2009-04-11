# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh/libssh-0.11.ebuild,v 1.5 2009/01/02 05:32:01 vapier Exp $

DESCRIPTION="access a working SSH implementation by means of a library"
HOMEPAGE="http://0xbadc0de.be/?part=libssh"
SRC_URI="http://www.0xbadc0de.be/libssh/${P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

DEPEND="sys-libs/zlib
	dev-libs/openssl"

src_install() {
	emake prefix="${D}/usr" install || die "make install failed"
	chmod a-x "${ED}"/usr/include/libssh/*
}
