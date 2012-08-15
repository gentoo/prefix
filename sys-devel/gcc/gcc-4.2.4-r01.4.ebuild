# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.2.4-r1.ebuild,v 1.11 2011/12/02 23:43:54 vapier Exp $

PATCH_VER="1.1"
UCLIBC_VER="1.0"

inherit toolchain flag-o-matic prefix

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3 LGPL-2.1 || ( GPL-3 libgcc libstdc++ ) FDL-1.2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
	kernel_Interix? ( || ( ${CATEGORY}/native-cctools >=${CATEGORY}/binutils-2.16 ) )
	!kernel_Darwin? ( !kernel_AIX? ( !kernel_Interix? (
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	) ) )"

src_unpack() {
	toolchain_src_unpack

	use vanilla && return 0

	# work around http://gcc.gnu.org/bugzilla/show_bug.cgi?id=33637
	epatch "${FILESDIR}"/4.2.2/targettools-checks.patch

	# http://bugs.gentoo.org/show_bug.cgi?id=201490
	epatch "${FILESDIR}"/4.2.2/gentoo-fixincludes.patch

	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=27516
	epatch "${FILESDIR}"/4.2.2/treelang-nomakeinfo.patch

	# call the linker without explicit target like on sparc
	epatch "${FILESDIR}"/solaris-i386-ld-emulation-4.2.patch

	# fix configure problem, bug #416577
	epatch "${FILESDIR}"/4.2.2/solarisx86.patch

	# add support for 64-bits native target on Solaris (includes fix for #416577)
	epatch "${FILESDIR}"/4.2.2/solarisx86_64.patch
	if [[ ${CHOST} == *-solaris* ]] ; then
		# fix nasty bootstrap problem: we need 4.2 due to no deps of MPC, GMP,
		# MPFR, but 4.2 doesn't know about *_sol2 ld targets of >=binutils-2.21
		# we likely have that one installed, so if so, we patch it to *_sol2
		if has_version '>=sys-devel/binutils-2.21' ; then
			einfo "Patching specs to target elf_*_sol2 for newer binutils"
			sed -i \
				-e '/TARGET_LD_EMULATION/s/elf_\(x86_64\|i386\)/elf_\1_sol2/g' \
				gcc/config/i386/sol2-10.h || die
			sed -i \
				-e 's/elf\(32\|64\)_sparc/&_sol2/g' \
				gcc/config/sparc/sol2-gld-bi.h || die
		fi
	fi

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
	# make long double be 64bit on intierx, as libc was built with VC++ (which
	# has 64 bit long doubles).
	epatch "${FILESDIR}"/${P}-interix-long-double.patch

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
	epatch "${FILESDIR}"/4.2.2/aix-pr46072.patch

	# try /usr/lib32 in 32bit profile on x86_64-linux (needs --enable-multilib)
	# but this does make sense in prefix only.
	use prefix && epatch "${FILESDIR}"/${P}-linux-x86-on-amd64.patch

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch

	epatch "${FILESDIR}"/4.2.2/aix-minimal-toc.patch
	epatch "${FILESDIR}"/4.2.2/aix61-longdouble64.patch
	epatch "${FILESDIR}"/4.2.2/aix-soname.patch
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
		*-interix*" bootstrap "*)
			# with suacomp, on interix, we need to have some header files
			# available, which complement the system headers. adding this
			# to CC/CXX is the only way to get a stage1 gcc built during
			# bootstrap. the rest will work as normal.
			tc-export CC CXX
			CC="${CC} -I${EPREFIX}/usr/include"
			CXX="${CXX} -I${EPREFIX}/usr/include"
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

	# create a small profile.d script, unsetting some of the bad
	# environment variables that the system could set from the outside.
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

