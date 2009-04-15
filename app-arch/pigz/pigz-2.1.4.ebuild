# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/pigz/pigz-2.1.4.ebuild,v 1.3 2009/04/14 09:39:38 armin76 Exp $

inherit eutils toolchain-funcs

DESCRIPTION="A parallel implementation of gzip."
HOMEPAGE="http://www.zlib.net/pigz/"
SRC_URI="http://www.zlib.net/pigz/${P}.tar.gz"

LICENSE="PIGZ"
SLOT="0"
KEYWORDS="~amd64-linux ~sparc64-solaris"
IUSE=""

DEPEND="sys-libs/zlib"
RDEPEND=${DEPEND}

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
