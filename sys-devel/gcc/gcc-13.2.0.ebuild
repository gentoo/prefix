# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TOOLCHAIN_PATCH_DEV="sam"
PATCH_GCC_VER="13.2.0"
PATCH_VER="7"
MUSL_VER="2"
MUSL_GCC_VER="13.2.0"

inherit toolchain

# Don't keyword live ebuilds
if ! tc_is_live && [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	# fails to compile on Solaris and macOS, need to check why
	: KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
	KEYWORDS="~arm64-macos ~x64-macos ~x64-solaris"
fi

# use alternate source for Apple M1 (also works for x86_64)
IANSGCCVER="gcc-13.2-darwin-r0"
SRC_URI+=" elibc_Darwin? (
https://github.com/iains/gcc-13-branch/archive/refs/tags/${IANSGCCVER}.tar.gz )"

# Technically only if USE=hardened *too* right now, but no point in complicating it further.
# If GCC is enabling CET by default, we need glibc to be built with support for it.
# bug #830454
RDEPEND="!prefix-guest? ( elibc_glibc? ( sys-libs/glibc[cet(-)?] ) )"
DEPEND="${RDEPEND}"
BDEPEND="
	kernel_linux? ( >=${CATEGORY}/binutils-2.30[cet(-)?] )
	kernel_Darwin? (
		|| ( ${CATEGORY}/binutils-apple ${CATEGORY}/native-cctools )
	)"

src_unpack() {
	if use elibc_Darwin ; then
		# just use Ian's source, not the main one
		S="${WORKDIR}/gcc-13-branch-${IANSGCCVER}"
	fi
	default
}

src_prepare() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		# https://bugs.gentoo.org/898610#c17
		# kill no_pie patch, it breaks things here
		rm "${WORKDIR}"/patch/09_all_nopie-all-flags.patch || die
		# fails on Darwin's sources
		rm "${WORKDIR}"/patch/81_all_match.p*.patch
	fi
	# doesn't apply on official and Darwin sources
	rm "${WORKDIR}"/patch/31_all_gm2_make_P_var.patch

	toolchain_src_prepare

	eapply_user

	eapply "${FILESDIR}"/${PN}-13-fix-cross-fixincludes.patch

	# make it have correct install_names on Darwin
	eapply -p1 "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch

	if [[ ${CHOST} == powerpc*-darwin* ]] ; then
		# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=44107
		sed -i -e 's|^ifeq (/usr/lib,|ifneq (/usr/lib,|' \
			libgcc/config/t-slibgcc-darwin || die
	fi

	if [[ ${CHOST} == *-solaris* ]] ; then
		# madvise is not available in the compatibility mode GCC uses,
		# posix_madvise however, is
		sed -i -e 's/madvise/posix_madvise/' gcc/cp/module.cc || die
	fi

	if [[ ${CHOST} == *-darwin* ]] ; then
		# our ld64 is a slight bit different, so tweak expression to not
		# get confused and break the build
		sed -i -e 's/grep ld64/grep :ld64/' gcc/configure || die

		# rip out specific macos version min
		sed -i -e 's/-mmacosx-version-min=11.0//' \
			libgcc/config/aarch64/t-darwin \
			libgcc/config/aarch64/t-heap-trampoline \
			|| die
	fi
}

src_configure() {
	local myconf=()
	case ${CTARGET}:" ${USE} " in
		powerpc*-darwin*)
			# bug #381179
			filter-flags "-mcpu=*" "-mtune=*"
			# bug #657522
			# A bug in configure checks whether -no-pie works, but the
			# compiler doesn't pass -no-pie onto the linker if -fno-PIE
			# isn't passed, so the configure check always finds -no-pie
			# is accepted.  (Likewise, when -fno-PIE is passed, the
			# compiler passes -no_pie onto the linker.)
			# Since our linker doesn't grok this, avoid above checks to
			# be run
			# NOTE: later ld64 does grok -no_pie, not -no-pie (as checked)
			export gcc_cv_c_no_fpie=no
			export gcc_cv_no_pie=no
		;;
		*-darwin20)
			# use sysroot with the linker, #756160
			export gcc_cv_ld_sysroot=yes
			;;
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			myconf+=( --with-gnu-ld --with-gnu-as --enable-largefile )
			# Solaris 11 defines this in its headers, but that causes a
			# mismatch whilst compiling, bug #657514
			#export ac_cv_func_aligned_alloc=no
			#export ac_cv_func_memalign=no
			#export ac_cv_func_posix_memalign=no
			append-ldflags -L"${EPREFIX}"/usr/lib \
				-Wl,-rpath -Wl,"${EPREFIX}"/usr/lib
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

	if [[ ${CHOST} == *-darwin ]] ; then
		# GCC' Darwin fork enables support for "-stdlib=libc++"
		# unconditionally, and its default include path is invalid,
		# causing package build failures due to missing header.
		# But more importantly, it breaks the assumption of many build
		# scripts and changes their CFLAGS and linking behaviors. The
		# situation is tricky and needs careful considerations.
		# For now, just disable support for "-stdlib=libc++".
		myconf+=( --with-gxx-libcxx-include-dir=no )
	fi

	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, and AIX /bin/sh is way too slow,
	# so force it to use $BASH (that portage uses) - it can't be EPREFIX
	# in case that doesn't exist yet
	export CONFIG_SHELL="${CONFIG_SHELL:-${BASH}}"
	toolchain_src_configure "${myconf[@]}"
}
