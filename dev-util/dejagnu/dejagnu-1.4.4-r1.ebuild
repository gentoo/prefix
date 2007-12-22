# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dejagnu/dejagnu-1.4.4-r1.ebuild,v 1.11 2006/04/11 16:32:51 flameeyes Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="framework for testing other programs"
HOMEPAGE="http://www.gnu.org/software/dejagnu/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE="doc"

DEPEND="virtual/libc
	dev-lang/tcl
	dev-tcltk/expect"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/dejagnu-ignore-libwarning.patch
}

src_test() {
	# if you dont have dejagnu emerged yet, you cant
	# run the tests ... crazy aint it :)
	type -p runtest || return 0
	make check || die "check failed :("
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README TODO
	use doc && dohtml -r doc/html/
}
