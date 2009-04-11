# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/devtodo/devtodo-0.1.20.ebuild,v 1.12 2008/08/10 13:13:13 jokey Exp $

inherit autotools eutils bash-completion flag-o-matic

DESCRIPTION="A nice command line todo list for developers"
HOMEPAGE="http://swapoff.org/DevTodo"
SRC_URI="http://swapoff.org/files/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=sys-libs/ncurses-5.2
	>=sys-libs/readline-4.1"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-gentoo.diff"
	epatch "${FILESDIR}/${P}-gcc43.patch"
	eautoreconf
}

src_compile() {
	replace-flags -O[23] -O1
	econf --sysconfdir="${EPREFIX}/etc/devtodo" || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog QuickStart README doc/scripts.sh \
	doc/scripts.tcsh doc/todorc.example || die "dodoc failed"

	dobashcompletion contrib/${PN}.bash-completion ${PN}
	rm contrib/${PN}.bash-completion
	docinto contrib
	dodoc contrib/*
}

pkg_postinst() {
	echo
	elog "Because of a conflict with app-misc/tdl, the tdl symbolic link"
	elog "and manual page have been removed."
	bash-completion_pkg_postinst
}
