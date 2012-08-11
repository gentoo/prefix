# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.1.2.ebuild,v 1.31 2011/12/02 23:43:54 vapier Exp $

PATCH_VER="1.3"
UCLIBC_VER="1.0"
D_VER="0.24"

inherit toolchain flag-o-matic

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-2 LGPL-2.1 FDL-1.2"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
	!kernel_Darwin? ( !kernel_AIX? (
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	) )"

src_unpack() {
	toolchain_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	# Fix cross-compiling
	epatch "${FILESDIR}"/4.1.0/gcc-4.1.0-cross-compile.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch

	epatch "${FILESDIR}"/4.1.0/gcc-4.1.0-fast-math-i386-Os-workaround.patch

	epatch "${FILESDIR}"/${P}-freebsd.patch
	epatch "${FILESDIR}"/${P}-darwin-fpic.patch

	if [[ ${CHOST} == *-solaris* ]] ; then
		# fix nasty bootstrap problem: we need 4.1 due to no deps of MPC, GMP,
		# MPFR, but 4.1 doesn't know about *_sol2 ld targets of >=binutils-2.21
		# we likely have that one installed, so if so, we patch it to *_sol2
		if has_version '>=sys-devel/binutils-2.21' ; then
			einfo "Patching specs to target elf_*_sol2 for newer binutils"
			sed -i \
				-e '/TARGET_LD_EMULATION/s/elf_\(x86_64\|i386\)/elf_\1_sol2/g' \
				gcc/config/i386/sol2-10.h || die
		fi
	fi
}

src_compile() {
	case ${CHOST} in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld"
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as"
		;;
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
	esac
	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, so force it into our own bash
	export CONFIG_SHELL="${BASH}"
	gcc_src_compile
}
