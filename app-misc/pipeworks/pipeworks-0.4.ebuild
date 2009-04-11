# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pipeworks/pipeworks-0.4.ebuild,v 1.10 2009/01/03 12:51:50 angelos Exp $

inherit toolchain-funcs

DESCRIPTION="a small utility that measures throughput between stdin and stdout"
HOMEPAGE="http://pipeworks.sourceforge.net/"
SRC_URI="mirror://sourceforge/pipeworks/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"

src_compile() {
	emake CC="$(tc-getCC) ${CFLAGS} ${LDFLAGS}" || die "emake failed"
}

src_install() {
	dobin pipeworks || die "dobin failed"
	doman pipeworks.1
	dodoc Changelog README
}
