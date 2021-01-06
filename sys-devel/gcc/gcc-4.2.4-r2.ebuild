# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.2.4-r1.ebuild,v 1.16 2014/01/19 01:51:34 dirtyepic Exp $

EAPI="5"

PATCH_VER="1.3"
UCLIBC_VER="1.0"

inherit eutils toolchain flag-o-matic prefix

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-2.1+ || ( GPL-3+ libgcc libstdc++ ) FDL-1.2+"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	!kernel_Darwin? (
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	)"

src_prepare() {
	toolchain_src_prepare

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

	# allow gcj compilation to succeed on platforms with libiconv
	epatch "${FILESDIR}"/gcj-${PV}-iconvlink.patch

	# try /usr/lib32 in 32bit profile on x86_64-linux (needs --enable-multilib)
	# but this does make sense in prefix only.
	use prefix && epatch "${FILESDIR}"/${P}-linux-x86-on-amd64.patch

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch

	epatch "${FILESDIR}"/4.2.2/ro-string.patch
}

src_configure() {
	case ${CTARGET}:" ${USE} " in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld --with-gnu-as"
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
	toolchain_src_configure
}

src_install() {
	toolchain_src_install

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
