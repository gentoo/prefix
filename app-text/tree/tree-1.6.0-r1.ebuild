# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/tree/tree-1.6.0-r1.ebuild,v 1.1 2012/05/27 23:17:52 mr_bones_ Exp $

EAPI=4
inherit toolchain-funcs flag-o-matic bash-completion-r1

DESCRIPTION="Lists directories recursively, and produces an indented listing of files."
HOMEPAGE="http://mama.indstate.edu/users/ice/tree/"
SRC_URI="ftp://mama.indstate.edu/linux/tree/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_prepare() {
	sed -i \
		-e 's:LINUX:__linux__:' tree.c \
		|| die "sed failed"
	mv doc/tree.1.fr doc/tree.fr.1
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} ${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		XOBJS="$(use elibc_glibc || echo strverscmp.o)"
}

src_install() {
	dobin tree
	doman doc/tree*.1
	dodoc CHANGES README*
	newbashcomp "${FILESDIR}"/${PN}.bashcomp ${PN}
}
