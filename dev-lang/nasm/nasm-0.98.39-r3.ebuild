# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/nasm/nasm-0.98.39-r3.ebuild,v 1.6 2008/12/07 05:58:55 vapier Exp $

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="groovy little assembler"
HOMEPAGE="http://nasm.sourceforge.net/"
SRC_URI="mirror://sourceforge/nasm/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"

DEPEND="dev-lang/perl
	doc? ( virtual/ghostscript sys-apps/texinfo )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-elf-visibility.patch
	if [ "$(gcc-major-version)" -eq "2" ] ; then
		sed -i \
			-e 's:-std=c99::g' \
			configure \
			|| die "sed failed"
	fi
	#security fix for bug #92991
	sed -i \
		-e '/vsprintf/c\    vsnprintf(buffer, sizeof(buffer), format, ap);
		' output/outieee.c \
		|| die "sed failed"
}

src_compile() {
	strip-flags
	econf || die

	if use build; then
		emake nasm || die "emake failed"
	else
		emake all || die "emake failed"
		emake rdf || die "emake failed"
		if use doc ; then
			emake doc || die "emake failed"
		fi
	fi
}

src_install() {
	if use build; then
		dobin nasm || die "dobin failed"
	else
		dobin nasm ndisasm rdoff/{ldrdf,rdf2bin,rdf2ihx,rdfdump,rdflib,rdx} \
			|| die "dobin failed"
		dosym /usr/bin/rdf2bin /usr/bin/rdf2com
		doman nasm.1 ndisasm.1
		dodoc AUTHORS CHANGES ChangeLog README TODO
		if use doc; then
			doinfo doc/info/*
			dohtml doc/html/*
			dodoc doc/nasmdoc.*
		fi
	fi
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="groovy little assembler"
HOMEPAGE="http://nasm.sourceforge.net/"
SRC_URI="mirror://sourceforge/nasm/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc build"

DEPEND="!build? ( dev-lang/perl )
	doc? ( virtual/ghostscript sys-apps/texinfo )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	
	use x86-macos && epatch ${FILESDIR}/${PN}-${PV}_apple-10.4.8.x86.diff
	
	epatch "${FILESDIR}"/${P}-elf-visibility.patch
	if [ "$(gcc-major-version)" -eq "2" ] ; then
		sed -i \
			-e 's:-std=c99::g' \
			configure \
			|| die "sed failed"
	fi
	#security fix for bug #92991
	sed -i \
		-e '/vsprintf/c\    vsnprintf(buffer, sizeof(buffer), format, ap);
		' output/outieee.c \
		|| die "sed failed"
}

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
