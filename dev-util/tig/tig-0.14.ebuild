# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/tig/tig-0.14.ebuild,v 1.1 2009/02/07 23:01:56 gregkh Exp $

inherit bash-completion

DESCRIPTION="Tig: text mode interface for git"
HOMEPAGE="http://jonas.nitro.dk/tig/"
SRC_URI="http://jonas.nitro.dk/tig/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"

DEPEND="sys-libs/ncurses"
RDEPEND="${DEPEND}
		dev-util/git"

src_compile() {
	econf CFLAGS="${CFLAGS}" || die "econf failed"
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"
	doman tig.1 tigrc.5
	dodoc manual.txt
	dohtml manual.html
	dobashcompletion contrib/tig-completion.bash
}
