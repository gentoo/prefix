# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/levee/levee-3.4o.ebuild,v 1.19 2008/05/25 15:52:56 loki_val Exp $

EAPI="prefix"

inherit eutils

IUSE=""

S=${WORKDIR}/${PN}
DESCRIPTION="Really tiny vi clone, for things like rescue disks"
HOMEPAGE="http://www.pell.chi.il.us/~orc/Code/"
SRC_URI="http://www.pell.chi.il.us/~orc/Code/${PN}.tar.gz"

SLOT="0"
LICENSE="levee"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"

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
