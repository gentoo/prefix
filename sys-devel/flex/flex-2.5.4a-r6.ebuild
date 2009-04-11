# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.4a-r6.ebuild,v 1.14 2008/12/07 03:08:55 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://lex.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.gz
	http://dev.gentoo.org/~vapier/dist/${P}-autoconf.patch.bz2
	mirror://gentoo/${P}-autoconf.patch.bz2"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static"

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
	epatch "${FILESDIR}"/${PN}-configure-LANG.patch
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
	make install DESTDIR="${D}" || die "make install failed"
	dodoc NEWS README
	dosym flex /usr/bin/lex
}
