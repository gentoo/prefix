# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: $

EAPI=5

MY_PN=${PN%%-headers}
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}.src"

inherit eutils

DESCRIPTION="Header files for libc++ required by e.g. libc++abi to be compiled"
HOMEPAGE="http://libcxx.llvm.org/"
SRC_URI="http://llvm.org/releases/${PV}/${MY_P}.src.tar.xz"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="~x64-macos ~x86-macos"
IUSE=""

src_prepare() {
	if [[ ${CHOST} == *darwin* ]] ; then
		[[ "${CHOST##*-darwin}" -le 10 ]] && \
			epatch "${FILESDIR}"/${PN}-3.5.1-cmath-conv.patch
		[[ "${CHOST##*-darwin}" -le 8 ]] && \
			epatch "${FILESDIR}"/${PN}-3.5.1-availability.patch
		rm -f include/CMakeLists.txt
	fi
}

src_compile() {
	:
}

src_install() {
	insinto /usr/include/c++/v1
	doins -r include/*
}
