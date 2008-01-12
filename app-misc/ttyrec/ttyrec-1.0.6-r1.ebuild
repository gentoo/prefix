# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ttyrec/ttyrec-1.0.6-r1.ebuild,v 1.2 2008/01/11 21:10:34 grobian Exp $

EAPI="prefix"

DESCRIPTION="tty recorder"
HOMEPAGE="http://namazu.org/~satoru/ttyrec/"
SRC_URI="http://namazu.org/~satoru/ttyrec/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"

src_compile() {
	local mycflags
	mycflags="${CFLAGS}"

	# Bug 106530.
	if [[ ${CHOST} == *-linux-gnu ]] ; then
		mycflags="${CFLAGS} -DSVR4"
	fi
	make CFLAGS="${mycflags}" || die
}

src_install() {
	dobin ttyrec ttyplay ttytime || die
	dodoc README
	doman *.1
}
