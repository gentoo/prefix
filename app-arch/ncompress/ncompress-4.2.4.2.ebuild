# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/ncompress/ncompress-4.2.4.2.ebuild,v 1.8 2007/11/13 15:48:44 jer Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Another uncompressor for compatibility"
HOMEPAGE="http://ncompress.sourceforge.net/"
SRC_URI="mirror://sourceforge/ncompress/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed \
		-e 's:options= :options= $(CFLAGS) -DNOFUNCDEF -DUTIME_H $(LDFLAGS) :' \
		-e "s:CC=cc:CC=$(tc-getCC):" \
		Makefile.def > Makefile
}

src_install() {
	dobin compress || die
	dosym compress /usr/bin/uncompress
	doman compress.1
	echo '.so compress.1' > "${ED}"/usr/share/man/man1/uncompress.1
	dodoc Acknowleds Changes LZW.INFO README
}
