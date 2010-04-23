# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.5.ebuild,v 1.2 2010/04/20 20:34:54 vapier Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://www.gzip.org/zlib/${P}.tar.bz2
	http://www.zlib.net/${P}.tar.bz2"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="!<dev-libs/libxml2-2.7.7" #309623

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.3-mingw-implib.patch #288212
	# trust exit status of the compiler rather than stderr #55434
	# -if test "`(...) 2>&1`" = ""; then
	# +if (...) 2>/dev/null; then
	sed -i 's|\<test "`\([^"]*\) 2>&1`" = ""|\1 2>/dev/null|' configure || die

	# also set soname and stuff on Solaris (with CHOST compensation fix as below)
	sed -i -e 's:Linux\* | linux\*:Linux\* | linux\* | SunOS\* | solaris\*:' configure || die
	# and compensate for our ebuild env having CHOST set
	sed -i -e 's:Darwin\*):Darwin\* | darwin\*):' configure || die

	# configure script isn't really /bin/sh, breaks on Solaris
	sed -i -e '1c\#!/usr/bin/env bash' configure || die

	# put libz.so.1 into libz.a on AIX
# fails, still necessary?
#	epatch "${FILESDIR}"/${PN}-1.2.3-shlib-aix.patch
	# patch breaks shared libs installation
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${P}-static.patch
}

src_compile() {
	case ${CHOST} in
	*-mingw*|mingw*)
		emake -f win32/Makefile.gcc prefix="${EPREFIX}"/usr STRIP= PREFIX=${CHOST}- || die
		;;
	*-mint*)
		./configure --static --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	*)  # not an autoconf script, so cant use econf
		./configure --shared --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	esac
}

src_install() {
	emake install DESTDIR="${D}" LDCONFIG=: || die
	dodoc FAQ README ChangeLog doc/*.txt

	case ${CHOST} in
	*-mingw*|mingw*)
		dobin zlib1.dll || die
		dolib libz.dll.a || die
		;;
	*) gen_usr_ldscript -a z ;;
	esac

	# on winnt, additionally install the .dll files.
	if [[ ${CHOST} == *-winnt* ]]; then
		into /
		dolib libz$(get_libname ${PV}).dll
	fi
}
