# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/pigz/pigz-2.1.5.ebuild,v 1.2 2009/11/02 17:58:48 vostorga Exp $

inherit eutils toolchain-funcs

DESCRIPTION="A parallel implementation of gzip."
HOMEPAGE="http://www.zlib.net/pigz/"
SRC_URI="http://www.zlib.net/pigz/${P}.tar.gz"

LICENSE="PIGZ"
SLOT="0"
KEYWORDS="~amd64-linux ~sparc64-solaris"
IUSE="test"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	test? ( app-arch/ncompress )"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-respect-flags.patch
}

src_compile() {
	tc-export CC
	emake || die "make failed"
}

src_install() {
	dobin ${PN} || die "Failed to install"
	dodoc README
}
