# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pal/pal-0.4.3.ebuild,v 1.1 2008/10/05 11:49:51 tove Exp $

inherit toolchain-funcs eutils prefix

DESCRIPTION="pal command-line calendar program"
HOMEPAGE="http://palcal.sourceforge.net/"
SRC_URI="mirror://sourceforge/palcal/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE="nls unicode"

RDEPEND=">=dev-libs/glib-2.0
	sys-libs/readline
	sys-libs/ncurses
	nls? ( virtual/libintl )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${P}/src"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-strip.patch
	epatch "${FILESDIR}"/${PV}-ldflags.patch
	if use unicode ; then
		if built_with_use sys-libs/ncurses unicode ; then
			sed -i "/^LIBS/s/-lncurses/&w/" "${S}"/Makefile || die
		else
			ewarn "Rebuild sys-libs/ncurses with unicode before you try"
			ewarn "to build app-misc/pal with unicode support!"
		fi
	fi

	epatch "${FILESDIR}"/${PN}-0.3.5_pre1-prefix.patch
	eprefixify Makefile.defs input.c Makefile
	sed -i -e 's/ -o root//g' {.,convert}/Makefile
}

src_compile() {
	emake CC="$(tc-getCC)" OPT="${CFLAGS}" LDOPT="${LDFLAGS}" \
		|| die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install-man install-bin install-share \
		|| die "make install failed"

	if use nls; then
		make DESTDIR="${D}" install-mo || die "make install-mo failed"
	fi

	dodoc "${WORKDIR}"/${P}/{ChangeLog,doc/example.css} || die "dodoc failed"
}
