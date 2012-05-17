# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/ncompress/ncompress-4.2.4.4.ebuild,v 1.7 2011/07/09 08:58:41 xarthisius Exp $

inherit toolchain-funcs

DESCRIPTION="Another uncompressor for compatibility"
HOMEPAGE="http://ncompress.sourceforge.net/"
SRC_URI="mirror://sourceforge/ncompress/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	dobin compress || die
	dosym compress /usr/bin/uncompress
	doman compress.1
	echo '.so compress.1' > "${ED}"/usr/share/man/man1/uncompress.1
	dodoc Acknowleds Changes LZW.INFO README
}
