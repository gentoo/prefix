# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCH_VER="1.1"
UCLIBC_VER="1.0"
CYGWINPORTS_GITREV="a03d77536f40d1a6335b6d313a4e4a4dff38ce66" # gcc-6.4.0-3

inherit eutils toolchain flag-o-matic

#KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	!prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.13 ) )
	kernel_linux? ( >=${CATEGORY}/binutils-2.20 )
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.13 ) )"
fi

src_prepare() {
	toolchain_src_prepare

	use vanilla && return 0

	# make sure 64-bits native targets don't screw up the linker paths
	epatch "${FILESDIR}"/no-libs-for-startfile.patch
	if use prefix; then
		epatch "${FILESDIR}"/4.5.2/prefix-search-dirs.patch
		# try /usr/lib32 in 32bit profile on x86_64-linux (needs
		# --enable-multilib), but this does make sense in prefix only
		epatch "${FILESDIR}"/${PN}-4.8.3-linux-x86-on-amd64.patch
	fi

	# make it have correct install_names on Darwin
	epatch "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch
}

src_configure() {
	local myconf=()
	case ${CTARGET}:" ${USE} " in
		powerpc*-darwin*)
			# bug #381179
			filter-flags "-mcpu=*" "-mtune=*"
		;;
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			myconf+=( --with-gnu-ld --with-gnu-as --enable-largefile )
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
	# least on Solaris, and AIX /bin/sh is way too slow,
	# so force it to use $BASH (that portage uses) - it can't be EPREFIX
	# in case that doesn't exist yet
	export CONFIG_SHELL="${CONFIG_SHELL:-${BASH}}"
	toolchain_src_configure "${myconf[@]}"
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
