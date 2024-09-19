# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TOOLCHAIN_PATCH_DEV="sam"
TOOLCHAIN_HAS_TESTS=1
PATCH_GCC_VER="14.1.0"
PATCH_VER="4"
MUSL_VER="1"
MUSL_GCC_VER="14.1.0"
PYTHON_COMPAT=( python3_{10..12} )

if [[ -n ${TOOLCHAIN_GCC_RC} ]] ; then
	# Cheesy hack for RCs
	MY_PV=$(ver_cut 1).$((($(ver_cut 2) + 1))).$((($(ver_cut 3) - 1)))-RC-$(ver_cut 5)
	MY_P=${PN}-${MY_PV}
	GCC_TARBALL_SRC_URI="mirror://gcc/snapshots/${MY_PV}/${MY_P}.tar.xz"
	TOOLCHAIN_SET_S=no
	S="${WORKDIR}"/${MY_P}
fi

inherit toolchain

if tc_is_live ; then
	# Needs to be after inherit (for now?), bug #830908
	EGIT_BRANCH=releases/gcc-$(ver_cut 1)
elif [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	# Don't keyword live ebuilds
	KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
fi

# use alternate source for Apple M1 (also works for x86_64)
SRC_URI+=" elibc_Darwin? ( https://raw.githubusercontent.com/Homebrew/formula-patches/d5dcb918a951b2dcf2d7702db75eb29ef144f614/gcc/gcc-14.2.0.diff -> gcc-14.2.0-arm64-darwin.patch )"
IUSE+=" bootstrap"

if [[ ${CATEGORY} != cross-* ]] ; then
	# Technically only if USE=hardened *too* right now, but no point in complicating it further.
	# If GCC is enabling CET by default, we need glibc to be built with support for it.
	# bug #830454
	RDEPEND="!prefix-guest? ( elibc_glibc? ( sys-libs/glibc[cet(-)?] ) )"
	DEPEND="${RDEPEND}"
fi

src_prepare() {
	# apply big arm64-darwin patch first thing
	use elibc_Darwin && eapply "${DISTDIR}"/${P}-arm64-darwin.patch

	# make sure 64-bits native targets don't screw up the linker paths
	eapply "${FILESDIR}"/gcc-12-no-libs-for-startfile.patch

	local p upstreamed_patches=(
		# add them here
	)
	for p in "${upstreamed_patches[@]}"; do
		rm -v "${WORKDIR}/patch/${p}" || die
	done

	toolchain_src_prepare
	#
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
		use bootstrap && eapply "${FILESDIR}"/${PN}-13-darwin14-bootstrap.patch

		# our ld64 is a slight bit different, so tweak expression to not
		# get confused and break the build
		sed -i -e "s/EGREP 'ld64|dyld'/& | head -n1/" \
			gcc/configure{.ac,} || die

		# rip out specific macos version min
		sed -i -e 's/-mmacosx-version-min=11.0//' \
			libgcc/config/aarch64/t-darwin \
			libgcc/config/aarch64/t-heap-trampoline \
			|| die
	fi

	eapply "${FILESDIR}"/${PN}-13-fix-cross-fixincludes.patch
	eapply_user
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
