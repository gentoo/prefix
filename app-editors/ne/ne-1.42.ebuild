# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/ne/ne-1.42.ebuild,v 1.8 2007/10/10 07:09:25 opfer Exp $

inherit toolchain-funcs

DESCRIPTION="the nice editor, easy to use for the beginner and powerful for the wizard"
HOMEPAGE="http://ne.dsi.unimi.it/"
SRC_URI="http://ne.dsi.unimi.it/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND=">=sys-libs/ncurses-5.2"
DEPEND="${RDEPEND}
	dev-lang/perl"

src_unpack() {
	unpack ${A}
	sed -i s/-O3// "${S}"/src/makefile
}

src_compile() {
	emake -j1 -C src ne OPTS="${CFLAGS}" CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	dobin src/ne || die "dobin failed"
	doman doc/ne.1 || die "doman failed"
	dohtml doc/*.html || die "dohtml failed"
	dodoc CHANGES README doc/*.{txt,ps,pdf,texinfo} doc/default.* || die "dodoc failed"
}
