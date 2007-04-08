# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/ircii/ircii-20060725.ebuild,v 1.5 2007/03/19 22:11:50 welp Exp $

EAPI="prefix"

inherit flag-o-matic

IUSE="ipv6 elibc_glibc"

DESCRIPTION="ircII is an IRC and ICB client that runs under most UNIX platforms."
SRC_URI="ftp://ircii.warped.com/pub/ircII/${P}.tar.bz2"
HOMEPAGE="http://www.eterna.com.au/ircii/"

RDEPEND="sys-libs/ncurses
	virtual/libiconv"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"

src_compile() {
	use elibc_glibc || append-ldflags -liconv
	econf $(use_enable ipv6) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"

	dodoc ChangeLog INSTALL NEWS README \
		doc/Copyright doc/crypto doc/VERSIONS doc/ctcp \
		|| die "dodoc failed"
}
