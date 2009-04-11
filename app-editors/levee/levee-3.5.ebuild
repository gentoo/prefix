# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/levee/levee-3.5.ebuild,v 1.2 2008/12/03 11:57:14 loki_val Exp $

inherit toolchain-funcs eutils

DESCRIPTION="Really tiny vi clone, for things like rescue disks"
HOMEPAGE="http://www.pell.chi.il.us/~orc/Code/"
SRC_URI="http://www.pell.chi.il.us/~orc/Code/levee/${P}.tar.gz"

SLOT="0"
LICENSE="levee"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"

IUSE=""
DEPEND="!app-text/lv
	sys-libs/ncurses"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.4o-darwin.patch
	epatch "${FILESDIR}"/${P}-QA.patch
}

src_compile() {
	export AC_CPP_PROG=$(tc-getCPP)
	export AC_PATH=${PATH}
	./configure.sh 	--prefix="${PREFIX}"/usr || die "configure failed"
	emake	CFLAGS="${CFLAGS} -Wall -Wextra ${LDFLAGS}" \
		CC=$(tc-getCC) || die "emake failed"
}

src_install() {
	emake PREFIX="${D}${EPREFIX}" install || die "emake install failed"
}
