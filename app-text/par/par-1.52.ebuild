# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/par/par-1.52.ebuild,v 1.10 2008/01/03 18:16:00 grobian Exp $

EAPI="prefix"

inherit toolchain-funcs

MY_P="Par${PV/./}"
DESCRIPTION="a paragraph reformatter, vaguely similar to fmt, but better"
HOMEPAGE="http://www.nicemice.net/par/"
SRC_URI="http://www.nicemice.net/par/${MY_P/./}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="!dev-util/par
	!app-arch/par"

S=${WORKDIR}/${MY_P}

src_compile() {
	make -f protoMakefile CC="$(tc-getCC) -c $CFLAGS" \
		LINK1="$(tc-getCC) $LDFLAGS" || die 'make failed'
}

src_install() {
	newbin par par-format || die
	doman par.1
	dodoc releasenotes par.doc
}
