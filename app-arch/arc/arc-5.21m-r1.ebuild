# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/arc/arc-5.21m-r1.ebuild,v 1.1 2007/07/14 14:25:43 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Create & extract files from DOS .ARC files"
HOMEPAGE="http://arc.sourceforge.net/"
SRC_URI="mirror://sourceforge/arc/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-compile-cleanups.patch
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-gentoo-fbsd.patch

	sed -i 's/CFLAGS = $(OPT) $(SYSTEM)/CFLAGS += $(SYSTEM)/' "${S}"/Makefile
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		OPT="${LDFLAGS}" \
		|| die "emake failed"
}

src_install() {
	dobin arc marc || die "dobin failed"
	doman arc.1
	dodoc Arc521.doc Arcinfo Changelog Readme
}
