# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.3-r1.ebuild,v 1.16 2013/03/03 09:18:24 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://www.gzip.org/zlib/${P}.tar.bz2
	http://www.zlib.net/${P}.tar.bz2"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-visibility-support.patch #149929
	epatch "${FILESDIR}"/${PN}-1.2.1-glibc.patch
	epatch "${FILESDIR}"/${PN}-1.2.1-build-fPIC.patch
	epatch "${FILESDIR}"/${PN}-1.2.1-configure.patch #55434
	epatch "${FILESDIR}"/${PN}-1.2.1-fPIC.patch
	epatch "${FILESDIR}"/${PN}-1.2.3-r1-bsd-soname.patch #123571
	epatch "${FILESDIR}"/${PN}-1.2.3-LDFLAGS.patch #126718
	epatch "${FILESDIR}"/${PN}-1.2.3-mingw-implib.patch #288212
	sed -i -e '/ldconfig/d' Makefile*

	# put libz.so.1 into libz.a on AIX
	epatch "${FILESDIR}"/${P}-shlib-aix.patch
}

src_compile() {
	tc-export AR CC RANLIB
	case ${CHOST} in
	*-mingw*|mingw*)
		export RC=${CHOST}-windres DLLWRAP=${CHOST}-dllwrap
		emake -f win32/Makefile.gcc prefix=/usr || die
		;;
	*-mint*)
		./configure --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/$(get_libdir) || die
		emake || die
		;;
	*)
		# not an autoconf script, so cant use econf
		./configure --shared --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/$(get_libdir) || die
		emake || die
		;;
	esac
}

src_install() {
	einstall libdir="${ED}"/$(get_libdir) || die
	rm "${ED}"/$(get_libdir)/libz.a
	insinto /usr/include
	doins zconf.h zlib.h

	doman zlib.3
	dodoc FAQ README ChangeLog algorithm.txt

	# we don't need the static lib in /lib
	# as it's only for compiling against
	dolib libz.a

	# all the shared libs go into /lib
	# for NFS based /usr
	case ${CHOST} in
	*-mingw*|mingw*)
		dobin zlib1.dll || die
		dolib libz.dll.a || die
		;;
	*-mint*)
		# no shared libraries here
		:
		;;
	*)
		into /
		dolib libz$(get_libname ${PV})
		( cd "${ED}"/$(get_libdir) ; chmod 755 libz*$(get_libname)* )
		[[ $(get_libname ${PV}) != $(get_libname) ]] && {
		dosym libz$(get_libname ${PV}) /$(get_libdir)/libz$(get_libname)
		dosym libz$(get_libname ${PV}) /$(get_libdir)/libz$(get_libname 1)
		}
		gen_usr_ldscript libz$(get_libname)
		;;
	esac

	# on winnt, additionally install the .dll files.
	if [[ ${CHOST} == *-winnt* ]]; then
		into /
		dolib libz$(get_libname ${PV}).dll
	fi
}
