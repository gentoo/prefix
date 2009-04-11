# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/rats/rats-2.1-r2.ebuild,v 1.7 2008/02/20 19:27:56 armin76 Exp $

inherit eutils

DESCRIPTION="RATS - Rough Auditing Tool for Security"
HOMEPAGE="http://www.fortifysoftware.com/security-resources/rats.jsp"
SRC_URI="http://www.fortifysoftware.com/servlet/downloads/public/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND="dev-libs/expat
		virtual/libc"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-add-getopt-trailing-null.patch
	epatch ${FILESDIR}/${P}-fix-null-pointers.patch
}

src_compile() {
	econf --datadir="${EPREFIX}/usr/share/${PN}/" || die
	emake || die
}

src_install () {
	einstall SHAREDIR="${ED}/usr/share/${PN}" MANDIR="${ED}/usr/share/man" || die
	dodoc README README.win32
}

pkg_postinst() {
	ewarn "Please be careful when using this program with it's force language"
	ewarn "option, '--language <LANG>' it may take huge amounts of memory when"
	ewarn "it tries to treat binary files as some other type."
}
