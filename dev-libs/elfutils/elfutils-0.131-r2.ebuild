# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/elfutils/elfutils-0.131-r2.ebuild,v 1.9 2009/02/14 05:40:18 ken69267 Exp $

inherit eutils

DESCRIPTION="Libraries/utilities to handle ELF objects (drop in replacement for libelf)"
HOMEPAGE="http://people.redhat.com/drepper/"
#SRC_URI="ftp://sources.redhat.com/pub/systemtap/${PN}/${P}.tar.gz"
SRC_URI="mirror://debian/pool/main/e/elfutils/elfutils_${PV}.orig.tar.gz"

LICENSE="OpenSoftware"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

# This pkg does not actually seem to compile currently in a uClibc
# environment (xrealloc errs), but we need to ensure that glibc never
# gets pulled in as a dep since this package does not respect virtual/libc
DEPEND="elibc_glibc? ( !prefix? ( >=sys-libs/glibc-2.3.2 ) )
	sys-devel/gettext
	sys-devel/autoconf
	>=sys-devel/binutils-2.15.90.0.1
	>=sys-devel/gcc-3.3.3
	!dev-libs/libelf"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gnu-inline.patch #204610
	epatch "${FILESDIR}"/${PN}-0.118-PaX-support.patch
	find . -name Makefile.in -print0 | xargs -0 sed -i -e 's:-W\(error\|extra\)::g'
	sed -i 's:\<off64_t\>:__off64_t:g' libelf/libelf.h || die #204502
}

src_compile() {
	econf \
		--program-prefix="eu-" \
		--enable-shared \
		|| die "./configure failed"
	emake || die
}

src_test() {
	env LD_LIBRARY_PATH="${S}/libelf:${S}/libebl:${S}/libdw:${S}/libasm" \
		make check || die "test failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS NOTES README THANKS TODO
}
