# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.4a-r6.ebuild,v 1.9 2005/09/16 11:19:41 agriffis Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://lex.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.gz
	http://dev.gentoo.org/~vapier/dist/${P}-autoconf.patch.bz2
	mirror://gentoo/${P}-autoconf.patch.bz2"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ~ppc-macos ppc64 s390 sh sparc x86"
IUSE="build static"

DEPEND=""

S=${WORKDIR}/${P/a/}

src_unpack() {
	unpack ${A}

	cd "${S}"
	# Some Redhat patches to fix various problems
	epatch "${FILESDIR}"/flex-2.5.4-glibc22.patch
	epatch "${FILESDIR}"/flex-2.5.4a-gcc3.patch
	epatch "${FILESDIR}"/flex-2.5.4a-gcc31.patch
	epatch "${FILESDIR}"/flex-2.5.4a-skel.patch

	# included autotools are crusty, lets polish em up
	epatch "${WORKDIR}"/${P}-autoconf.patch
}

src_compile() {
	tc-export AR CC RANLIB
	use static && append-ldflags -static
	econf || die "econf failed"
	emake -j1 .bootstrap || die "emake bootstrap failed"
	emake || die "emake failed"
}

src_test() {
	make bigcheck || die "Test phase failed"
}

src_install() {
	make install DESTDIR="${DEST}" || die "make install failed"

	if use build ; then
		rm -r "${D}"/usr/{include,lib,share}
	else
		dodoc NEWS README
	fi

	dosym flex /usr/bin/lex
}
