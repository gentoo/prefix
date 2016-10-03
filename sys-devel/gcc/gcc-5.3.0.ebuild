# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

PATCH_VER="1.0"
UCLIBC_VER="1.0"
CYGWINPORTS_GITREV="f44d762eb3551ea0d81aa8e4b428bcb7caabb628" # gcc-5.3.0-3

# Hardened gcc 4 stuff
PIE_VER="0.6.5"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

inherit eutils toolchain flag-o-matic

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	!prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.8 ) )
	kernel_linux? ( >=${CATEGORY}/binutils-2.20 )
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.8 ) )"
fi

src_prepare() {
	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi
	# Fedora/RedHat ships glibc-2.15+ with some nasty warnings that cause
	# configure checks for most system headers to fail, resulting in bugs
	# compiling e.g. gcc itself, bug #433333
	if [[ -e /usr/include/features.h ]] ; then
		grep -qF "_FORTIFY_SOURCE requires compiling with optimization" \
			/usr/include/features.h && \
				EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	toolchain_src_prepare

	use vanilla && return 0

	# make sure solaris-x64 doesn't misdetect tls support, bug #505446
	#epatch "${FILESDIR}"/4.7.2/solaris-x64-tls-gnu-as.patch

	# make sure 64-bits native targets don't screw up the linker paths
	#epatch "${FILESDIR}"/4.7.1/solaris-searchpath.patch
	epatch "${FILESDIR}"/no-libs-for-startfile.patch
	if use prefix; then
		epatch "${FILESDIR}"/4.5.2/prefix-search-dirs.patch
		# try /usr/lib32 in 32bit profile on x86_64-linux (needs
		# --enable-multilib), but this does make sense in prefix only
		epatch "${FILESDIR}"/${PN}-4.8.3-linux-x86-on-amd64.patch
	fi

	# make it have correct install_names on Darwin
	epatch "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch
	# filename based versioning of libgcc_s for AIX
	#epatch "${FILESDIR}"/gcc-4.8.4-aix-soname-libgcc.patch.xz
	# let --with-specs=-pthread work for libgcc_s on AIX without multilib
	#epatch "${FILESDIR}"/gcc-4.8.4-aix-pthread-specs.patch
	# drop -B flag when ./nm encounters -P
	#epatch "${FILESDIR}"/gcc-4.8.4-aix-soname-nm-weak.patch
	# support --with-aix-soname=aix|both|svr4 for libtool libs
	#epatch "${FILESDIR}"/gcc-4.8.4-aix-soname-libtool.patch.xz
	#epatch "${FILESDIR}"/gcc-4.8.4-aix-soname-regen.patch.xz
	#epatch "${FILESDIR}"/gcc-4.8-aix-extref.patch # PR target/65058
	if [[ ${CHOST} == *-aix* ]]; then
		# -fPIC breaks stage2/3 comparison, use per-build random seed
		local myseed=$(echo $(
			head -c32 /dev/urandom | uuencode - | tr -d -c a-zA-Z0-9_+/.,
		))
		echo "STAGE2_CFLAGS += -frandom-seed=${myseed}" >> config/mh-ppc-aix
		echo "STAGE3_CFLAGS += -frandom-seed=${myseed}" >> config/mh-ppc-aix
		is_crosscompile ||
		echo "CFLAGS_FOR_TARGET += -frandom-seed=${myseed}" >> config/mh-ppc-aix
		# build large insn-*.o one at a time
		epatch "${FILESDIR}"/gcc-4.8.4-lowmem-build.patch
	fi

	if [[ ${CHOST} == *-mint* ]] ; then
		epatch "${FILESDIR}"/4.3.2/${PN}-4.3.2-mint3.patch
		epatch "${FILESDIR}"/4.7.2/mint1.patch
		epatch "${FILESDIR}"/4.4.1/${PN}-4.4.1-mint3.patch
		epatch "${FILESDIR}"/4.7.2/mint2.patch
		epatch "${FILESDIR}"/4.7.2/mint3.patch
		epatch "${FILESDIR}"/4.7.2/pr52391.patch
		epatch "${FILESDIR}"/4.7.2/mint-unroll.patch
		epatch "${FILESDIR}"/4.7.2/pr52773.patch
		epatch "${FILESDIR}"/4.7.2/pr52714.patch
	fi

	#Use -r1 for newer piepatchet that use DRIVER_SELF_SPECS for the hardened specs.
	#[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env-r1.patch
}

src_configure() {
	local myconf=()
	case ${CTARGET}:" ${USE} " in
		powerpc*-darwin*)
			# bug #381179
			filter-flags "-mcpu=*" "-mtune=*"
		;;
		*-mint*)
			myconf+=( --enable-multilib )
		;;
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			myconf+=( --with-gnu-ld --with-gnu-as )
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			myconf+=( --without-gnu-ld --without-gnu-as --disable-lto )
			append-ldflags -Wl,-bbigtoc,-bmaxdata:0x10000000 # bug#194635
			# we have backports of the aix-soname upstream patches
			myconf+=( --with-aix-soname=svr4 )
			# Always behave on AIX as if:
			#   -fPIC was passed (packages know that "everything on AIX is PIC")
			#   -pthread was passed (#266548)
			#   -Wl,-bsvr4 was passed (runtime linking, hold -L paths off the runpath)
			#   -Wl,-G,-bernotok was passed for shared libraries (runtime linking, --no-undefined)
			myconf+=( --with-specs="-fPIC -pthread %x{-bsvr4} %{shared:%x{-G} %x{-bernotok}}" )
		;;
		ia64*-*-hpux*)
			# Always behave as if -pthread were passed on HPUX (#266548)
			myconf+=( --with-specs=-pthread )
			;;
		*-interix*)
			# disable usage of poll() on interix, since poll() only
			# works on the /proc filesystem (.......)
			export glibcxx_cv_POLL=no

			# if using the old system as, gcc's configure script fails
			# to detect that as cannot handle .lcomm with alignment.
			# on interix, it is rather easy to detect the as, since there
			# is only _one_ build of it with a fixed date in the version
			# header...
			if as --version | grep 20021111 > /dev/null 2>&1; then
				einfo "preventing gcc from detecting .lcomm alignment option in interix system as."
				export gcc_cv_as_lcomm_with_alignment=no
			fi
		;;
		i[34567]86-*-linux*:*" prefix "*)
			# to allow the linux-x86-on-amd64.patch become useful, we need
			# to enable multilib, even if there is just one multilib option.
			myconf+=( --enable-multilib )
			if [[ ${CBUILD:-${CHOST}} == "${CHOST}" ]]; then
				# we might be on x86_64-linux, but don't do cross-compile, so
				# tell the host-compiler to really create 32bits (for stage1)
				# (real x86-linux-gcc also accept -m32).
				append-flags -m32
			fi
		;;
	esac

	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, and AIX /bin/sh is ways too slow,
	# so force it to use $BASH (that portage uses) - it can't be EPREFIX
	# in case that doesn't exist yet
	export CONFIG_SHELL="${CONFIG_SHELL:-${BASH}}"
	toolchain_src_configure "${myconf[@]}"
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
