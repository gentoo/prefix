# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TOOLCHAIN_PATCH_DEV="sam"
PATCH_VER="7"
PATCH_GCC_VER="12.1.0"
MUSL_VER="4"
MUSL_GCC_VER="12.1.0"

inherit toolchain

# Don't keyword live ebuilds
if ! tc_is_live && [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

# use alternate source for Apple M1 (also works for x86_64)
IANSGCCVER="gcc-12.1-darwin-r0"
SRC_URI+=" elibc_Darwin? (
https://github.com/iains/gcc-12-branch/archive/refs/tags/${IANSGCCVER}.tar.gz )"

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
		S="${WORKDIR}/gcc-12-branch-${IANSGCCVER}"
	fi
	default
}

src_prepare() {
	toolchain_src_prepare

	eapply_user

	# fix build for macOS 13 Ventura
	eapply "${FILESDIR}"/gcc-12.1.0-recognize-mmacosx-version-min-13.0-and-newer.patch
	eapply "${FILESDIR}"/gcc-12.1.0-avoid-null-terminated-name-collision-with-macos-13-sdk.patch

	# make sure 64-bits native targets don't screw up the linker paths
	eapply "${FILESDIR}"/gcc-12-no-libs-for-startfile.patch
	if use prefix; then
		eapply "${FILESDIR}"/gcc-12-prefix-search-dirs.patch
		# try /usr/lib32 in 32bit profile on x86_64-linux (needs
		# --enable-multilib), but this does make sense in prefix only
		eapply -p0 "${FILESDIR}"/${PN}-4.8.3-linux-x86-on-amd64.patch
	fi

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
		arm64-*-darwin*)
			# only supported from darwin21, so no conflict with above
			# case switch
			# for the time being use system flex, for our doesn't work
			# here (while it does fine elsewhere), #778014
			export ac_cv_prog_FLEX=/usr/bin/flex
			;;
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			myconf+=( --with-gnu-ld --with-gnu-as --enable-largefile )
			# Solaris 11 defines this in its headers, but that causes a
			# mismatch whilst compiling, bug #657514
			export ac_cv_func_aligned_alloc=no
			export ac_cv_func_memalign=no
			export ac_cv_func_posix_memalign=no
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
