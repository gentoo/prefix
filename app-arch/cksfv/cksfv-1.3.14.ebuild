# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cksfv/cksfv-1.3.14.ebuild,v 1.1 2009/09/05 17:34:49 patrick Exp $

inherit toolchain-funcs

DESCRIPTION="SFV checksum utility (simple file verification)"
HOMEPAGE="http://zakalwe.fi/~shd/foss/cksfv/"
SRC_URI="http://zakalwe.fi/~shd/foss/cksfv/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND=""

src_compile() {
	# note: not an autoconf configure script
	./configure \
		--compiler=$(tc-getCC) \
		--prefix="${EPREFIX}"/usr \
		--package-prefix="${D}" \
		--bindir="${EPREFIX}"/usr/bin \
		--mandir="${EPREFIX}"/usr/share/man || die
	emake || die
}

src_install() {
	emake install || die
	dodoc ChangeLog README TODO
}
