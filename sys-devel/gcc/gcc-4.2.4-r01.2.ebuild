# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.2.4-r1.ebuild,v 1.5 2010/01/09 12:58:57 ulm Exp $

PATCH_VER="1.1"
UCLIBC_VER="1.0"

ETYPE="gcc-compiler"

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=no #${SPLIT_SPECS-true} hard disable until #106690 is fixed

inherit toolchain flag-o-matic prefix

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"

LICENSE="GPL-3 LGPL-2.1 || ( GPL-3 libgcc libstdc++ ) FDL-1.2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	fortran? (
		>=dev-libs/gmp-4.2.1
		>=dev-libs/mpfr-2.2.0_p10
	)
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen dev-util/dejagnu )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	sys-devel/flex
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
	kernel_Interix? ( || ( ${CATEGORY}/native-cctools >=${CATEGORY}/binutils-2.16 ) )
	!kernel_Darwin? ( !kernel_AIX? ( !kernel_Interix? (
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	) ) )"
PDEPEND=">=sys-devel/gcc-config-1.4"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.3.6 ) )"
fi

src_unpack() {
	gcc_src_unpack

	# work around http://gcc.gnu.org/bugzilla/show_bug.cgi?id=33637
	epatch "${FILESDIR}"/4.2.2/targettools-checks.patch

	# http://bugs.gentoo.org/show_bug.cgi?id=201490
	epatch "${FILESDIR}"/4.2.2/gentoo-fixincludes.patch

	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=27516
	epatch "${FILESDIR}"/4.2.2/treelang-nomakeinfo.patch

	# add support for 64-bits native target on Solaris
	epatch "${FILESDIR}"/4.2.2/solarisx86_64.patch

	# make sure 64-bits native targets don't screw up the linker paths
	epatch "${FILESDIR}"/solaris-searchpath.patch
	epatch "${FILESDIR}"/no-libs-for-startfile.patch
	# replace nasty multilib dirs like ../lib64 that occur on --disable-multilib
	if use prefix; then
		epatch "${FILESDIR}"/4.2.2/prefix-search-dirs.patch
		eprefixify "${S}"/gcc/gcc.c
	fi

	# interix patch from http://gcc.gnu.org/bugzilla/show_bug.cgi?id=15212
	epatch "${FILESDIR}"/4.2.2/interix-x86.patch.bz2
	# gcc sources are polluted with old stuff for interix 3.5 not needed here
	epatch "${FILESDIR}"/4.2.2/interix-3.5-x86.patch
	# define _ALL_SOURCE by default on Interix
	epatch "${FILESDIR}"/${P}-interix-all-source.patch
	# support for the $@#$% dir structure on 64bit SUA
	epatch "${FILESDIR}"/${P}-interix-x64-support.patch

	if [[ ${CHOST} == *-mint* ]] ; then
		epatch "${FILESDIR}"/gcc-4.2.3-mint.patch
		epatch "${FILESDIR}"/gcc-4.2.3-mint2.patch
	fi

	# http://gcc.gnu.org/PR20366
	epatch "${FILESDIR}"/${P}-aix-largefiles.patch

	# Always behave as if -pthread were passed on AIX (#266548)
	epatch "${FILESDIR}"/4.2.2/aix-force-pthread.patch

	# Always behave as if -Wl,-brtl were passed on AIX (#213277)
	epatch "${FILESDIR}"/4.2.2/aix-runtimelinking.patch

	# allow gcj compilation to succeed on platforms with libiconv
	epatch "${FILESDIR}"/gcj-${PV}-iconvlink.patch

	epatch "${FILESDIR}"/${PN}-4.2-pa-hpux-libgcc_s-soname.patch
	epatch "${FILESDIR}"/${PN}-4.2-ia64-hpux-always-pthread.patch
	epatch "${FILESDIR}"/4.2.2/pr26189-pa.patch
	epatch "${FILESDIR}"/4.2.2/aix-bnoerok.patch
	epatch "${FILESDIR}"/4.2.2/aix-lineno.patch

	# try /usr/lib32 in 32bit profile on x86_64-linux (needs --enable-multilib)
	# but this does make sense in prefix only.
	use prefix && epatch "${FILESDIR}"/${P}-linux-x86-on-amd64.patch

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch

	epatch "${FILESDIR}"/4.2.2/aix-minimal-toc.patch
	epatch "${FILESDIR}"/4.2.2/aix61-longdouble64.patch
}

src_compile() {
	case ${CTARGET}:" ${USE} " in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld --with-gnu-as"
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as"
			append-ldflags -Wl,-bbigtoc,-bmaxdata:0x10000000 # bug#194635
		;;
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
		i[34567]86-*-linux*:*" prefix "*)
			# to allow the linux-x86-on-amd64.patch become useful, we need
			# to enable multilib, even if there is just one multilib option.
			EXTRA_ECONF="${EXTRA_ECONF} --enable-multilib"
			if [[ ${CBUILD:-${CHOST}} == "${CHOST}" ]]; then
				# we might be on x86_64-linux, but don't do cross-compile, so
				# tell the host-compiler to really create 32bits (for stage1)
				# (real x86-linux-gcc also accept -m32).
				tc-export CC CXX
				CC="${CC} -m32"
				CXX="${CC} -m32"
			fi
		;;
	esac
	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, and AIX /bin/sh is ways too slow,
	# so force it to use $BASH (that portage uses) - it can't be EPREFIX
	# in case that doesn't exist yet
	export CONFIG_SHELL="${BASH}"
	gcc_src_compile
}

src_install() {
	toolchain_src_install

	if [[ ${CTARGET} == *-interix* ]] && ! is_crosscompile; then
		# interix delivers libdl and dlfcn.h with gcc-3.3.
		# Since those parts are perfectly usable by this gcc (and
		# required for example by perl), we simply can reuse them.
		# As libdl is in /usr/lib, we only need to copy dlfcn.h.
		# When cross compiling for interix once, ensure that sysroot
		# contains dlfcn.h.
		cp /opt/gcc.3.3/include/dlfcn.h "${ED}${INCLUDEPATH}" \
		|| die "Cannot gain /opt/gcc.3.3/include/dlfcn.h"
	fi

	if [[ ${CTARGET} == *-interix3* ]]; then
		# interix 3.5 has no stdint.h and no inttypes.h. This breaks
		# so many packages, that i just install interix 5.2's stdint.h
		# which should be ok.
		cp "${FILESDIR}"/interix-3.5-stdint.h "${ED}${INCLUDEPATH}/stdint.h" \
		|| die "Cannot install stdint.h for interix3"
	fi

	# create a small profile.d script, unsetting some of the bad
	# environment variables that the sustem could set from the outside.
	# (GCC_SPECS, GCC_EXEC_PREFIX, CPATH, LIBRARY_PATH, LD_LIBRARY_PATH,
	#  C_INCLUDE_PATH, CPLUS_INCLUDE_PATH, LIBPATH, SHLIB_PATH, LIB, INCLUDE,
	#  LD_LIBRARY_PATH_32, LD_LIBRARY_PATH_64).
	# Maybe there is a better location for doing this ...? Feel free to move
	# it there if you want to.

	cat > "${T}"/00-gcc-paths.sh <<- _EOF
		#!/bin/env bash
		# GCC specific variables
		unset GCC_SPECS GCC_EXEC_PREFIX
		# include path variables
		unset CPATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH INCLUDE
		# library path variables
		unset LIBRARY_PATH LD_LIBRARY_PATH LIBPATH SHLIB_PATH LIB LD_LIBRARY_PATH_32 LD_LIBRARY_PATH_64
	_EOF

	insinto /etc/profile.d
	doins "${T}"/00-gcc-paths.sh
}

