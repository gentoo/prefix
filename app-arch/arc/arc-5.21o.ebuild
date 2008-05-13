# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/arc/arc-5.21o.ebuild,v 1.6 2008/05/13 14:12:31 jer Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Create & extract files from DOS .ARC files"
HOMEPAGE="http://arc.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P/o/m}-darwin.patch
	epatch "${FILESDIR}"/${P/o/m}-gentoo-fbsd.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	sed -i -e 's/CFLAGS = $(OPT) $(SYSTEM)/CFLAGS += $(SYSTEM)/' Makefile
}

src_compile() {
	emake CC="$(tc-getCC)" OPT="${LDFLAGS}" || die "emake failed."
}

src_install() {
	dobin arc marc
	doman arc.1
	dodoc Arc521.doc Arcinfo Changelog Readme
}
