# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycrypto/pycrypto-2.0.1-r5.ebuild,v 1.15 2006/10/17 07:12:24 uberlord Exp $

EAPI="prefix"

inherit eutils distutils toolchain-funcs flag-o-matic

DESCRIPTION="Python Cryptography Toolkit"
HOMEPAGE="http://www.amk.ca/python/code/crypto.html"
SRC_URI="http://www.amk.ca/files/python/crypto/${P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="bindist gmp test"

RDEPEND="virtual/python
	gmp? ( dev-libs/gmp )"
DEPEND="${RDEPEND}
	test? ( =dev-python/sancho-0.11-r1 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	use bindist && epatch "${FILESDIR}"/${P}-bindist.patch
	epatch "${FILESDIR}"/${P}-sha256.patch
	epatch "${FILESDIR}"/${P}-gmp.patch
	epatch "${FILESDIR}"/pycrypto-2.0.1-uint32.patch
	epatch "${FILESDIR}"/${P}-sancho-package-rename.patch
}

src_compile() {
	use gmp \
		&& export USE_GMP=1 \
		|| export USE_GMP=0
	# sha256 hashes occasionally trigger ssp when built with
	# -finline-functions (implied by -O3).
	gcc-specs-ssp && append-flags -fno-inline-functions
	distutils_src_compile
}

src_test() {
	export PYTHONPATH=$(ls -d "${S}"/build/lib.*/)
	python ./test.py || die "test failed"
	if use test ; then
		local x
		cd test
		for x in test_*.py ; do
			python ${x} || die "${x} failed"
		done
	fi
}

DOCS="ACKS ChangeLog PKG-INFO README TODO Doc/pycrypt.tex"
