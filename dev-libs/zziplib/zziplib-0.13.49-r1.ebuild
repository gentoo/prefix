# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/zziplib/zziplib-0.13.49-r1.ebuild,v 1.14 2009/01/07 17:48:46 ken69267 Exp $

inherit libtool fixheadtails eutils

DESCRIPTION="Lightweight library used to easily extract data from files archived in a single zip file"
HOMEPAGE="http://zziplib.sourceforge.net/"
SRC_URI="mirror://sourceforge/zziplib/${P}.tar.bz2"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="sdl test"

RDEPEND=">=dev-lang/python-2.3
	sys-libs/zlib
	sdl? ( >=media-libs/libsdl-1.2.6 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	test? ( app-arch/zip )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-parallel-docs.patch #249153
	epatch "${FILESDIR}"/${P}-python.patch
	epatch "${FILESDIR}"/${P}-configure-sed.patch #240556
	epatch "${FILESDIR}"/${P}-SDL-test.patch
	epatch "${FILESDIR}"/${P}-sparc-aligned-access.patch #239472
	sed -i '/^Libs:/s:@LDFLAGS@::' configure || die #235511
	sed -i '/^zzip-postinstall:/s:^:disabled-:' Makefile.in || die
	ht_fix_file configure docs/Makefile.in uses/depcomp
	elibtoolize
}

src_compile() {
	econf $(use_enable sdl) || die
	emake || die "emake failed"
}

src_test() {
	# need this because `make test` will always return true
	# tests fail with -j > 1 (bug #241186)
	emake -j1 check || die "make check failed"
}

src_install() {
	emake DESTDIR="${D}" install install-man3 || die "make install failed"
	dodoc ChangeLog README TODO
	dohtml docs/*
}
