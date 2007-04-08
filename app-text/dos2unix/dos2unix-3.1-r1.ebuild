# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dos2unix/dos2unix-3.1-r1.ebuild,v 1.11 2007/02/08 21:12:38 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Dos2unix converts DOS or MAC text files to UNIX format"
HOMEPAGE="none"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
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
	make -s clean || die
}

src_install() {
	dobin dos2unix || die
	dosym dos2unix /usr/bin/mac2unix

	doman dos2unix.1
	dosym dos2unix.1 /usr/share/man/man1/mac2unix.1
}
