# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zip/zip-2.32-r1.ebuild,v 1.2 2008/01/16 18:46:59 armin76 Exp $

EAPI="prefix"

inherit toolchain-funcs eutils flag-o-matic

DESCRIPTION="Info ZIP (encryption support)"
HOMEPAGE="http://www.info-zip.org/"
SRC_URI="ftp://ftp.info-zip.org/pub/infozip/src/zip${PV//.}.tar.gz"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="crypt"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/zip-2.3-unix_configure-pic.patch
	epatch "${FILESDIR}"/${PN}-2.31-exec-stack.patch
	epatch "${FILESDIR}"/${PN}-2.32-build.patch
}

src_compile() {
	tc-export CC CPP
	use crypt || append-flags -DNO_CRYPT
	append-lfs-flags
	emake -f unix/Makefile generic || die
}

src_install() {
	dobin zip zipnote zipsplit || die
	doman man/zip.1
	dosym zip.1 /usr/share/man/man1/zipnote.1
	dosym zip.1 /usr/share/man/man1/zipzplit.1
	if use crypt ; then
		dobin zipcloak || die
		dosym zip.1 /usr/share/man/man1/zipcloak.1
	fi
	dodoc BUGS CHANGES MANUAL README TODO WHATSNEW WHERE proginfo/*.txt
}
