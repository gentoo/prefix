# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/nrg2iso/nrg2iso-0.4-r1.ebuild,v 1.11 2009/09/23 15:15:41 patrick Exp $

inherit toolchain-funcs

DESCRIPTION="Converts Nero nrg CD-images to iso"
HOMEPAGE="http://gregory.kokanosky.free.fr/v4/linux/nrg2iso.en.html"
SRC_URI="http://gregory.kokanosky.free.fr/v4/linux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=""

src_compile() {
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o nrg2iso nrg2iso.c || die "compile failed."
}

src_install() {
	dobin nrg2iso || die "dobin failed."
	dodoc CHANGELOG
}
