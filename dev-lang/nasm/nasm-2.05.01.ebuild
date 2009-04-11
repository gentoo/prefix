# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/nasm/nasm-2.05.01.ebuild,v 1.3 2009/01/11 15:12:56 maekke Exp $

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="groovy little assembler"
HOMEPAGE="http://nasm.sourceforge.net/"
SRC_URI="mirror://sourceforge/nasm/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="doc"

DEPEND="dev-lang/perl
	doc? ( virtual/ghostscript sys-apps/texinfo )"
RDEPEND=""

src_compile() {
	strip-flags
	econf || die

	emake all || die "emake failed"
	emake rdf || die "emake failed"
	if use doc ; then
		emake doc || die "emake failed"
	fi
}

src_install() {
	dobin nasm ndisasm rdoff/{ldrdf,rdf2bin,rdf2ihx,rdfdump,rdflib,rdx} \
		|| die "dobin failed"
	dosym /usr/bin/rdf2bin /usr/bin/rdf2com
	doman nasm.1 ndisasm.1
	dodoc AUTHORS CHANGES ChangeLog README TODO
	if use doc ; then
		doinfo doc/info/*
		dohtml doc/html/*
		dodoc doc/nasmdoc.*
	fi
}
