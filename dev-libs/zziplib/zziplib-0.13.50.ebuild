# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/zziplib/zziplib-0.13.50.ebuild,v 1.2 2008/12/31 22:40:02 vapier Exp $

inherit libtool fixheadtails eutils flag-o-matic

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
	test? ( app-arch/zip )
	kernel_Darwin? ( app-text/xmlto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.13.49-parallel-docs.patch #249153
	epatch "${FILESDIR}"/${PN}-0.13.49-python.patch
	epatch "${FILESDIR}"/${PN}-0.13.50-configure-sed.patch #240556
	epatch "${FILESDIR}"/${PN}-0.13.49-SDL-test.patch
	epatch "${FILESDIR}"/${PN}-0.13.50-sparc-aligned-access.patch #239472
	sed -i '/^Libs:/s:@LDFLAGS@::' configure || die #235511
	sed -i '/^zzip-postinstall:/s:^:disabled-:' Makefile.in || die
	ht_fix_file configure docs/Makefile.in uses/depcomp
	elibtoolize
}

src_compile() {
	use sparc && append-flags -DZZIP_HAVE_ALIGNED_ACCESS_REQUIRED
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

	if [[ ${CHOST} == *-darwin* ]] ; then
		# I really got tired of this package, bug #240566
		rm "${ED}"/usr/$(get_libdir)/libzzip\*.so.{10,11,12}
	fi
}
