# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.4a-r6.ebuild,v 1.13 2007/02/28 22:23:35 genstef Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://lex.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.gz
	http://dev.gentoo.org/~vapier/dist/${P}-autoconf.patch.bz2
	mirror://gentoo/${P}-autoconf.patch.bz2"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
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

	if use build ; then
		rm -r "${ED}"/usr/{include,lib,share}
	else
		dodoc NEWS README
	fi

	dosym flex /usr/bin/lex
}
