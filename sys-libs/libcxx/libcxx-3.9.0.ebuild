# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id $

EAPI=5

ESVN_REPO_URI="http://llvm.org/svn/llvm-project/libcxx/trunk"

[ "${PV%9999}" != "${PV}" ] && SCM="subversion" || SCM=""

inherit ${SCM} flag-o-matic toolchain-funcs cmake-multilib

DESCRIPTION="New implementation of the C++ standard library, targeting C++11"
HOMEPAGE="http://libcxx.llvm.org/"
if [ "${PV%9999}" = "${PV}" ] ; then
	SRC_URI="http://llvm.org/releases/${PV}/${P}.src.tar.xz"
	S="${WORKDIR}/${P}.src"
else
	SRC_URI=""
fi

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="~x64-macos ~x86-macos"
else
	KEYWORDS=""
fi
REQUIRED_USE="kernel_Darwin? ( libcxxabi !static-abi-lib )"
IUSE="elibc_glibc libcxxrt +libcxxabi static-libs static-abi-lib test"

RDEPEND="
	!kernel_Darwin? (
		libcxxrt? ( >=sys-libs/libcxxrt-0.0_p20130725[static-libs?,${MULTILIB_USEDEP}] )
		!libcxxrt? ( >=sys-devel/gcc-4.7[cxx] )
	)
	kernel_Darwin? (
		=sys-libs/libcxx-headers-${PV}
		=sys-libs/libcxxabi-${PV}
		sys-devel/clang
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/clang )
	app-arch/xz-utils
	static-abi-lib? (
		libcxxabi? ( sys-libs/libcxxabi[static-libs] )
		!libcxxabi? (
			libcxxrt? ( sys-libs/libcxxrt[static-libs] )
		)
	)
	"

DOCS=( CREDITS.TXT )

pkg_setup() {
	if [[ ${CHOST} == *darwin* ]] ; then
		MY_CC=$(tc-getCC)
		MY_CXX=$(tc-getCXX)
		if [[ ${MY_CC} != *clang* || ${MY_CXX} != *clang++* ]] ; then
			eerror "${PN} needs to be built with clang++. Please do not override"
			eerror "CC ($MY_CC) and CXX ($MY_CXX)"
			eerror "or point them at clang and clang++ respectively."
			die
		fi
	fi
	if ! use libcxxabi && ! use libcxxrt ; then
		ewarn "You have disabled USE=libcxxrt. This will build ${PN} against"
		ewarn "libsupc++. Please note that this is not well supported."
		ewarn "In particular, static linking will not work."
	fi
	if [[ $(gcc-version) < 4.7 ]] && [[ $(tc-getCXX) != *clang++* ]] ; then
		eerror "${PN} needs to be built with clang++ or gcc-4.7 or later."
		eerror "Please use gcc-config to switch to gcc-4.7 or later version."
		die
	fi
}

src_prepare() {
	sed -i -e "/set.LLVM_CMAKE_PATH.*\\/cmake\\/modules/s@cmake/modules@cmake@" cmake/Modules/HandleOutOfTreeLLVM.cmake

	# The library can only be built as either shared or static. So use two
	# separate build dirs with separate configurations.
	BUILD_DIR_SHARED=${WORKDIR}/${P}_build
	BUILD_DIR_STATIC=${WORKDIR}/${P}_build_static
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_PATH=${EPREFIX}/usr/share/llvm
		-DLIBCXX_INSTALL_HEADERS=NO
	)

	# make sure we build multilib on OSX, because llvm insists on
	# building multilib too
	[[ ${CHOST} == *86*-darwin* ]] && append-flags -arch i386 -arch x86_64

	if use libcxxabi ; then
		mycmakeargs+=(
			-DLIBCXX_CXX_ABI=libcxxabi 
			# avoid guessing of libcxxabi version by installed SDK discovered
			# via xc-run - we know better because we require a libcxxabi version
			# matching our own
			-DLIBCXX_LIBCPPABI_VERSION=2
			# avoid configure warning about not being able to find cxxabi.h
			-DLIBCXX_CXX_ABI_INCLUDE_PATHS=${EPREFIX}/usr/include
		)
	elif use libcxxrt ; then
		mycmakeargs+=( -DLIBCXX_CXX_ABI=libcxxrt )
	else
		mycmakeargs+=( -DLIBCXX_CXX_ABI=libsupc++ )
	fi

	use static-abi-lib && mycmakeargs+=( -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON )
	use test && mycmakeargs+=( -DLIBCXX_INCLUDE_TESTS=ON )

	BUILD_DIR=${BUILD_DIR_SHARED} cmake-multilib_src_configure
	if use static-libs ; then
		mycmakeargs+=( -DLIBCXX_ENABLE_SHARED=NO )
		BUILD_DIR=${BUILD_DIR_STATIC} cmake-multilib_src_configure
	fi
}

src_compile() {
	BUILD_DIR=${BUILD_DIR_SHARED} cmake-multilib_src_compile

	# reconfigure and recompile for additional static libs if enabled
	use static-libs  && \
		BUILD_DIR=${BUILD_DIR_STATIC} cmake-multilib_src_compile
}

src_test() {
	BUILD_DIR=${BUILD_DIR_SHARED} cmake-multilib_src_test
	use static-libs && \
		BUILD_DIR=${BUILD_DIR_STATIC} cmake-multilib_src_test
}

multilib_src_test() {
	cmake-utils_src_make check-libcxx
}

src_install() {
	BUILD_DIR=${BUILD_DIR_SHARED} cmake-multilib_src_install
	use static-libs && \
		BUILD_DIR=${BUILD_DIR_STATIC} cmake-multilib_src_install
}

multilib_src_install_all() {
	einstalldocs
}

pkg_postinst() {
	elog "This package (${PN}) is mainly intended as a replacement for the C++"
	elog "standard library when using clang."
	elog "To use it, instead of libstdc++, use:"
	elog "    clang++ -stdlib=libc++"
	elog "to compile your C++ programs."
}
