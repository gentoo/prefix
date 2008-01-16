# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/ttcp/ttcp-1.12.ebuild,v 1.12 2005/11/12 18:50:13 kumba Exp $

EAPI="prefix"

inherit toolchain-funcs eutils

IUSE=""
DESCRIPTION="Tool to test TCP and UDP throughput"
HOMEPAGE="http://ftp.arl.mil/~mike/ttcp.html"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~mips-linux ~x86-linux ~ppc-macos"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A} ; cd ${S}
	use amd64 && epatch ${FILESDIR}/ttcp-1.12-amd64.patch
}

src_compile() {
	$(tc-getCC) ${CFLAGS} -o ttcp sgi-ttcp.c || die "compile failed"
}

src_install() {
	dobin ttcp
	newman sgi-ttcp.1 ttcp.1
}
