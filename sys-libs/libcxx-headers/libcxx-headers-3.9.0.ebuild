# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: $

EAPI=5

MY_PN=${PN%%-headers}
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}.src"

inherit eutils cmake-utils

DESCRIPTION="Header files for libc++ required by e.g. libc++abi to be compiled"
HOMEPAGE="http://libcxx.llvm.org/"
SRC_URI="http://llvm.org/releases/${PV}/${MY_P}.src.tar.xz"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="~x64-macos ~x86-macos"
IUSE=""

src_prepare() {
	sed -i -e "/set.LLVM_CMAKE_PATH.*\\/cmake\\/modules/s@cmake/modules@cmake@" \
		cmake/Modules/HandleOutOfTreeLLVM.cmake

	if [[ ${CHOST} == *darwin* ]] ; then
		[[ "${CHOST##*-darwin}" -le 10 ]] && \
			epatch "${FILESDIR}"/${PN}-3.5.1-cmath-conv.patch
		[[ "${CHOST##*-darwin}" -le 8 ]] && \
			epatch "${FILESDIR}"/${PN}-3.5.1-availability.patch
	fi
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_PATH=${EPREFIX}/usr/share/llvm
		# disable installation and indirectly build of libc++ because we only
		# want the headers
		-DLIBCXX_INSTALL_LIBRARY=NO
		# disable libc++experimental as well because it will re-enable the
		# build of libc++
		-DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=NO 
	)

	cmake-utils_src_configure
}
