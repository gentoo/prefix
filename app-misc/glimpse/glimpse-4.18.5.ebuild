# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/glimpse/glimpse-4.18.5.ebuild,v 1.11 2008/01/11 21:00:12 grobian Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="A index/query system to search a large set of files quickly"
HOMEPAGE="http://webglimpse.net/"
SRC_URI="http://webglimpse.net/trial/${P}.tar.gz"

LICENSE="glimpse"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="static"

RDEPEND="!dev-libs/tre
	!app-text/agrep"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i \
		-e "s:CC=.*:CC=$(tc-getCC):" \
		-e 's:-O3 -fomit-frame-pointer:$(OPTIMIZEFLAGS):' \
		dynfilters/Makefile.in \
		|| die "removing -O3 failed"
	sed -i \
		-e '/^CFLAGS/s:$: $(OPTIMIZEFLAGS):' \
		{agrep,compress,index}/Makefile.in \
		Makefile.in \
		libtemplate/{template,util}/Makefile.in \
		|| die "inserting OPTIMIZEFLAGS failed"
	sed -i \
		-e 's:$(mandir):&/man1/:' \
		Makefile.in agrep/Makefile.in \
		|| die "adding man1 to man install dir failed"
}

src_compile() {
	use static && append-ldflags -static

	econf || die
	emake -j1 OPTIMIZEFLAGS="${CFLAGS}" || die
}

src_install() {
	einstall || die
}
