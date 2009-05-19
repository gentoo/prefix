# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ragel/ragel-6.5.ebuild,v 1.1 2009/05/18 18:13:12 flameeyes Exp $

inherit eutils

DESCRIPTION="Compiles finite state machines from regular languages into executable code."
HOMEPAGE="http://www.complang.org/ragel/"
SRC_URI="http://www.complang.org/ragel/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

# 6.5 release lacks some needed files
RESTRICT="test"

src_compile() {
	econf --docdir=/usr/share/doc/${PF} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dobin ragel/ragel || die "dobin failed"
	doman doc/ragel.1 || die "doman failed"
	dodoc README TODO || die "dodoc failed"
}
