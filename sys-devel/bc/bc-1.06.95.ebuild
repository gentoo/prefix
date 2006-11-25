# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bc/bc-1.06.95.ebuild,v 1.2 2006/10/18 11:13:56 uberlord Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Handy console-based calculator utility"
HOMEPAGE="http://www.gnu.org/software/bc/bc.html"
SRC_URI="ftp://alpha.gnu.org/gnu/bc/${P}.tar.bz2
	mirror://gnu/bc/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="libedit readline static"

RDEPEND="readline? ( >=sys-libs/readline-4.1 >=sys-libs/ncurses-5.2 )
	libedit? ( || ( sys-freebsd/freebsd-lib dev-libs/libedit ) )"
DEPEND="${RDEPEND}
	sys-devel/flex"

src_compile() {
	local myconf
	if use readline ; then
		myconf="--with-readline --without-libedit"
	elif use libedit ; then
		myconf="--without-readline --with-libedit"
	else
		myconf="--without-readline --without-libedit"
	fi
	use static && append-ldflags -static
	econf ${myconf} || die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS FAQ NEWS README ChangeLog
}
