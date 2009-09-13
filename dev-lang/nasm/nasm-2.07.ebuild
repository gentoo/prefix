# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/nasm/nasm-2.07.ebuild,v 1.3 2009/09/12 19:31:03 mr_bones_ Exp $

EAPI=2
inherit autotools eutils toolchain-funcs flag-o-matic

DESCRIPTION="groovy little assembler"
HOMEPAGE="http://nasm.sourceforge.net/"
SRC_URI="http://www.nasm.us/pub/nasm/releasebuilds/${PV/_}/${P/_}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos"
IUSE="doc"

DEPEND="dev-lang/perl
	doc? ( virtual/ghostscript sys-apps/texinfo )"
RDEPEND=""

S=${WORKDIR}/${P/_}

src_configure() {
	strip-flags
	econf
}

src_compile() {
	emake nasmlib.o || die
	emake all || die
	if use doc ; then
		emake doc || die
	fi
}

src_install() {
	emake INSTALLROOT="${D}" install install_rdf || die
	dodoc AUTHORS CHANGES ChangeLog README TODO
	if use doc ; then
		doinfo doc/info/*
		dohtml doc/html/*
		dodoc doc/nasmdoc.*
	fi
}
