# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/elfutils/elfutils-0.144.ebuild,v 1.1 2010/02/04 08:12:04 dirtyepic Exp $

inherit eutils

DESCRIPTION="Libraries/utilities to handle ELF objects (drop in replacement for libelf)"
HOMEPAGE="http://people.redhat.com/drepper/"
#SRC_URI="ftp://sources.redhat.com/pub/systemtap/${PN}/${P}.tar.gz"
#SRC_URI="mirror://debian/pool/main/e/elfutils/elfutils_${PV}.orig.tar.gz"
SRC_URI="https://fedorahosted.org/releases/e/l/elfutils/${P}.tar.bz2"

LICENSE="GPL-2-with-exceptions"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="bzip2 lzma nls test zlib"

# This pkg does not actually seem to compile currently in a uClibc
# environment (xrealloc errs), but we need to ensure that glibc never
# gets pulled in as a dep since this package does not respect virtual/libc
RDEPEND="zlib? ( >=sys-libs/zlib-1.2.2.3 )
	bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/xz-utils )"
DEPEND="${RDEPEND}
	elibc_glibc? ( !prefix? ( >=sys-libs/glibc-2.7 ) )
	nls? ( sys-devel/gettext )
	>=sys-devel/flex-2.5.4a
	sys-devel/m4
	>=sys-devel/binutils-2.15.90.0.1
	>=sys-devel/gcc-4.1.2
	!dev-libs/libelf"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.118-PaX-support.patch
	epatch "${FILESDIR}"/${PN}-0.143-configure.patch #287130
	epatch "${FILESDIR}"/${P}-sloppy-include.patch
	find . -name Makefile.in -print0 | xargs -0 sed -i -e 's:-W\(error\|extra\)::g'
	use test || sed -i -e 's: tests::' Makefile.in #226349
}

src_compile() {
	econf \
		$(use_enable nls) \
		--program-prefix="eu-" \
		$(use_with zlib) \
		$(use_with bzip2 bzlib) \
		$(use_with lzma)

	emake || die
}

src_test() {
	env LD_LIBRARY_PATH="${S}/libelf:${S}/libebl:${S}/libdw:${S}/libasm" \
		emake -j1 check || die "test failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS NOTES README THANKS TODO
}
