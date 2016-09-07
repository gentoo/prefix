# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id $

EAPI=5

inherit flag-o-matic

S="${WORKDIR}/${P}.src"

inherit eutils

DESCRIPTION="New implementation of low level support for a standard C++ library"
HOMEPAGE="http://libcxxabi.llvm.org/"
SRC_URI="http://llvm.org/releases/${PV}/${P}.src.tar.xz"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="~x64-macos ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	=sys-libs/libcxx-headers-${PV}
	sys-devel/clang"

pkg_setup() {
	if [[ ${CHOST} == *darwin* ]] ; then
		MY_CC=$(tc-getCC)
		MY_CXX=$(tc-getCXX)
		if [[ ${MY_CC} != *clang* || ${MY_CXX} != *clang++* ]] ; then
			eerror "${PN} needs to be built with clang++. Please do not override"
			eerror "CC ($MY_CC) and CXX ($MY_CXX)"
			eerror "or point them at clang and eerror clang++ respectively."
			die
		fi
		return
	fi
}

src_configure() {
	tc-export CC CXX
}

src_prepare() {
	# libc++abi needs stack unwinding functions provided by libSystem on Mac OS X
	# >= 10.6. On < 10.6 they're in libgcc_s. So force link against that.
	# Additionally, the crt1.o provided by our gcc-apple toolchain isn't
	# universal. Since that's needed for linking any program on OSX <
	# 10.7, universal support is effectively broken on those older OSXes
	# even if clang and libc++{,abi} were to support it. So we can just
	# disable universal compilation.
	gcc_s=gcc_s.1
	[[ "${CHOST##*-darwin}" -eq 9 ]] && gcc_s=gcc_s.10.5
	[[ "${CHOST##*-darwin}" -eq 8 ]] && gcc_s=gcc_s.10.4
	[[ "${CHOST##*-darwin}" -le 9 ]] && \
		sed -i -e "s,-lSystem,-lSystem -l${gcc_s},g" \
			-e "s,-arch i386 -arch x86_64,,g" \
			lib/buildit

	# assert.h refers to eprintf which is nowhere to be found. That's why
	# everyone (libstdc++, clang compiler-rt) bring their own
	# implementation. Ours is nicked from Apple's patch to libstdc++-39.
	[[ "${CHOST##*-darwin}" -le 8 ]] && \
		epatch "${FILESDIR}"/${PN}-3.5.1-eprintf.patch

	sed -i -e "s,/usr/lib/libc++abi\.dylib,${EPREFIX}/usr/lib/libc++abi.dylib,g" \
		lib/buildit
}

src_compile() {
	cd "${S}/lib" || die
	export TRIPLE=-apple-
	./buildit || die
}

src_install() {
	dolib.so lib/libc++*dylib

	# do not install unwind.h and others since they're only in-source
	# build-time dependencies
	insinto /usr/include
	doins -r include/cxxabi.h
	doins -r include/__cxxabi_config.h
}
