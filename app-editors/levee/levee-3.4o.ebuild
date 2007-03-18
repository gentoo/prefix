# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/levee/levee-3.4o.ebuild,v 1.18 2006/05/12 01:30:38 tcort Exp $

EAPI="prefix"

inherit eutils

IUSE=""

S=${WORKDIR}/${PN}
DESCRIPTION="Really tiny vi clone, for things like rescue disks"
HOMEPAGE="http://www.pell.chi.il.us/~orc/Code/"
SRC_URI="http://www.pell.chi.il.us/~orc/Code/${PN}.tar.gz"

SLOT="0"
LICENSE="levee"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND="sys-libs/ncurses"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	sed -i -e "/^CFLAGS/ s:-O:${CFLAGS}:" Makefile
	make LIBES=-lncurses || die
}

src_install() {
	exeinto /usr/bin
	newexe lev lv
	doman lv.1
}
