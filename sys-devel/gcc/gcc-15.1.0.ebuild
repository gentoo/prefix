# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Maintenance notes and explanations of GCC handling are on the wiki:
# https://wiki.gentoo.org/wiki/Project:Toolchain/sys-devel/gcc

TOOLCHAIN_PATCH_DEV="sam"
TOOLCHAIN_HAS_TESTS=1
PATCH_GCC_VER="15.1.0"
PATCH_VER="1"
MUSL_VER="1"
MUSL_GCC_VER="15.1.0"
PYTHON_COMPAT=( python3_{10..14} )

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
	EGIT_BRANCH=master
elif [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	# Don't keyword live ebuilds
	KEYWORDS="~amd64 ~x86 ~arm64-macos ~x64-macos ~x64-solaris"
	:;
fi

# use alternate source for Apple M1 (also works for x86_64)
SRC_URI+=" elibc_Darwin? ( https://raw.githubusercontent.com/Homebrew/formula-patches/575ffcaed6d3112916fed77d271dd3799a7255c4/gcc/gcc-15.1.0.diff -> ${P}-arm64-darwin.patch )"

if [[ ${CATEGORY} != cross-* ]] ; then
	# Technically only if USE=hardened *too* right now, but no point in complicating it further.
	# If GCC is enabling CET by default, we need glibc to be built with support for it.
	# bug #830454
	RDEPEND="!prefix-guest? ( elibc_glibc? ( sys-libs/glibc[cet(-)?] ) )"
	DEPEND="${RDEPEND}"
fi

src_prepare() {
	local p upstreamed_patches=(
		# add them here
	)
	for p in "${upstreamed_patches[@]}"; do
		rm -v "${WORKDIR}/patch/${p}" || die
	done

	toolchain_src_prepare

	# apply big arm64-darwin patch first thing
	use elibc_Darwin && eapply "${DISTDIR}"/${PN}-15.1.0-arm64-darwin.patch

	# run as with - on pipe (for Clang 16)
	eapply "${FILESDIR}"/${PN}-14.2.0-darwin-as-dash-pipe.patch

	# fix build with libintl-0.23
	eapply "${FILESDIR}"/${PN}-14.2.0-libintl-setlocale.patch

	# make sure 64-bits native targets don't screw up the linker paths
	eapply "${FILESDIR}"/gcc-12-no-libs-for-startfile.patch

	# make it have correct install_names on Darwin
	eapply -p1 "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch

	if [[ ${CHOST} == *-solaris* ]] ; then
		# codylib requires network socket libs to link
		sed -i -e 's:(LDFLAGS) :&-L/lib/64 -lsocket -lnsl : ' \
			c++tools/Makefile.in || die
		sed -i -e '/^LIBS =/s:=:= -L/lib/64 -lsocket -lnsl:' \
			gcc/Makefile.in || die
	fi

	eapply "${FILESDIR}"/${PN}-13-fix-cross-fixincludes.patch
	eapply_user
}

src_configure() {
	local myconf=()
	case ${CTARGET}:" ${USE} " in
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
