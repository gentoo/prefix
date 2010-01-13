# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/calc/calc-2.12.4.0.ebuild,v 1.2 2010/01/07 17:21:15 bicatali Exp $

EAPI=2
inherit eutils

DESCRIPTION="An arbitrary precision C-like arithmetic system"
HOMEPAGE="http://www.isthe.com/chongo/tech/comp/calc/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE=""

DEPEND=">=sys-libs/ncurses-5.2
	>=sys-libs/readline-4.2"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-prefix.patch
}

src_compile() {
	# parallel compilation hard to fix. better to leave upstream.
	emake -j1 \
		DEBUG="${CFLAGS}" \
		CALCPAGER="${PAGER}" \
		USE_READLINE="-DUSE_READLINE" \
		READLINE_LIB="-lreadline -lhistory -lncurses" \
		all || die "emake failed"

	if echo "${LD_PRELOAD}" | grep -q "sandbox"; then
		ewarn "Can't run check when running in sandbox - see bug #59676"
	else
		make chk || die "Check failed"
	fi
}

src_install() {
	emake T="${D}" LIBDIR="/usr/$(get_libdir)" install || die "emake install failed"
	dodoc BUGS CHANGES LIBRARY README
}
