# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dog/dog-1.7-r2.ebuild,v 1.10 2008/02/04 18:07:51 grobian Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Dog is better than cat"
HOMEPAGE="http://jl.photodex.com/dog/"
SRC_URI="http://jl.photodex.com/dog/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/${P}-check-ctime.diff
	epatch ${FILESDIR}/${PV}-manpage-touchup.patch
	epatch ${FILESDIR}/${P}-64bit-goodness.patch
	sed -i \
		-e 's,^CFLAGS,#CFLAGS,' \
		-e "s,gcc,$(tc-getCC)," \
		Makefile || die "sed Makefile failed"
}

src_install() {
	dobin dog || die
	doman dog.1
	dodoc README AUTHORS
}
