# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-text/tree/tree-1.5.1.1.ebuild,v 1.11 2008/01/17 04:07:56 kumba Exp $

EAPI="prefix"

inherit toolchain-funcs bash-completion

DESCRIPTION="Lists directories recursively, and produces an indented listing of files."
HOMEPAGE="http://mama.indstate.edu/users/ice/tree/"
SRC_URI="ftp://mama.indstate.edu/linux/tree/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DCYGWIN" \
		LDFLAGS="${LDFLAGS}" \
		|| die "emake failed"
}

src_install() {
	dobin tree || die "dobin failed"
	doman man/tree.1
	dodoc CHANGES README*
	dobashcompletion "${FILESDIR}"/${PN}.bashcomp
}
