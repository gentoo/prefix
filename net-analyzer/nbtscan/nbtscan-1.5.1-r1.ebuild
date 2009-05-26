# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/nbtscan/nbtscan-1.5.1-r1.ebuild,v 1.11 2009/05/26 02:28:42 jer Exp $

inherit eutils

DESCRIPTION="NBTscan is a program for scanning IP networks for NetBIOS name information"
HOMEPAGE="http://www.inetcat.net/software/nbtscan.html"
SRC_URI="http://www.sourcefiles.org/Networking/Tools/Miscellanenous/${P}.tar.gz"
SRC_URI="http://www.inetcat.net/software/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="virtual/libc"

S=${WORKDIR}/${P}a

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-script-whitespace.patch
}

src_compile() {
	./configure --host=${CHOST} --prefix="${EPREFIX}"/usr  || die
	emake CFLAGS="${CFLAGS}" || die
}

src_install () {
	dobin nbtscan
	dodoc ChangeLog README
}
