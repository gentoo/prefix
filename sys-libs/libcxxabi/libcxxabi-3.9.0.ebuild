# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id $

EAPI=5

inherit flag-o-matic eutils cmake-multilib

S="${WORKDIR}/${P}.src"

DESCRIPTION="New implementation of low level support for a standard C++ library"
HOMEPAGE="http://libcxxabi.llvm.org/"
SRC_URI="http://llvm.org/releases/${PV}/${P}.src.tar.xz"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="~x64-macos ~x86-macos"
IUSE="static-libs"

RDEPEND=""
DEPEND="${RDEPEND}
	=sys-libs/libcxx-headers-${PV}"

# note the abscense of a requirement to compile with clang on OS X - it
# actually compiles and works with recent gcc as well

src_prepare() {
	sed -i -e "/set.LLVM_CMAKE_PATH.*\\/cmake\\/modules/s@cmake/modules@cmake@" CMakeLists.txt
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_PATH=${EPREFIX}/usr/share/llvm
		-DLIBCXXABI_LIBCXX_INCLUDES=${EPREFIX}/usr/include/c++/v1
		# silence warning "LIBCXXABI_LIBCXX_PATH was not specified and couldn't
		# be infered" which is redundant because we have successfully provided
		# the libc++ include path via LIBCXXABI_LIBCXX_INCLUDES already
		-DLIBCXXABI_LIBCXX_PATH=shutup
	)

	use static-libs && \
		mycmakeargs+=( -DLIBCXXABI_ENABLE_STATIC=ON ) || \
		mycmakeargs+=( -DLIBCXXABI_ENABLE_STATIC=OFF )

	cmake-multilib_src_configure
}

multilib_src_install_all() {
	# do not install unwind.h and others since they're only in-source
	# build-time dependencies
	insinto /usr/include
	doins -r include/cxxabi.h
	doins -r include/__cxxabi_config.h
}
