# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/nrg2iso/nrg2iso-0.4-r1.ebuild,v 1.8 2007/04/28 06:36:45 corsair Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Converts Nero nrg CD-images to iso"
HOMEPAGE="http://gregory.kokanosky.free.fr/v4/linux/nrg2iso.en.html"
SRC_URI="http://gregory.kokanosky.free.fr/v4/linux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="virtual/libc"

src_compile() {
	$(tc-getCC) ${CFLAGS} -o nrg2iso nrg2iso.c || die "failed to compile"
}

src_install() {
	dobin nrg2iso || die
	dodoc CHANGELOG || die
}
