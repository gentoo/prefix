# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/calc/calc-2.12.2.2.ebuild,v 1.5 2008/06/02 22:39:34 coldwind Exp $

inherit eutils multilib

DESCRIPTION="An arbitrary precision C-like arithmetic system"
HOMEPAGE="http://www.isthe.com/chongo/tech/comp/calc/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE=""

DEPEND=">=sys-libs/ncurses-5.2
	>=sys-libs/readline-4.2"

RDEPEND="${DEPEND}
		>=sys-apps/less-348"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-libdir-fix.patch
	epatch "${FILESDIR}"/${P}-prefix.patch

	sed -e "s:LIBDIR= /usr/lib:LIBDIR= ${EPREFIX}/usr/$(get_libdir):" \
		-e "s:^\(INCDIR\|BINDIR\|CALC_SHAREDIR\|MANDIR\)= :\1= ${EPREFIX}:" \
		-i Makefile || die "Failed to fix multilib in makefile"
}

src_compile() {
	make \
		T="${D}" \
		DEBUG="${CFLAGS}" \
		CALCPAGER=less \
		USE_READLINE="-DUSE_READLINE" \
		READLINE_LIB="-lreadline -lhistory -lncurses" \
		all \
	|| die
	if echo "${LD_PRELOAD}" | grep -q "sandbox"; then
		ewarn "Can't run check when running in sandbox - see bug #59676"
	else
		make chk || die "Check failed"
	fi
}

src_install() {
	make T="${D}" install || die
	dodoc BUGS CHANGES LIBRARY README
}
