# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dos2unix/dos2unix-3.1-r2.ebuild,v 1.12 2008/09/16 12:04:34 pva Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Dos2unix converts DOS or MAC text files to UNIX format"
HOMEPAGE="none"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris"
IUSE=""

DEPEND=""
RDEPEND="!app-text/hd2u"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}.patch
	epatch "${FILESDIR}"/${P}-segfault.patch
	epatch "${FILESDIR}"/${P}-includes.patch
	epatch "${FILESDIR}"/${P}-preserve-file-modes.patch
	epatch "${FILESDIR}"/${P}-manpage-update.patch
	epatch "${FILESDIR}"/${P}-safeconv.patch
	epatch "${FILESDIR}"/${P}-workaround-rename-EXDEV.patch
	sed -i -e 's:\(^#endif \).*:\1:' \
			-e 's:\(^#else \).*:\1:' dos2unix.c dos2unix.h
	rm -f dos2unix mac2unix mac2unix.1 *~ *.orig core
}

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	dobin dos2unix || die
	dosym dos2unix /usr/bin/mac2unix

	doman dos2unix.1
	dosym dos2unix.1 /usr/share/man/man1/mac2unix.1
}
