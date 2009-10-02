# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycrypto/pycrypto-2.0.1-r8.ebuild,v 1.9 2009/10/02 01:08:28 arfrever Exp $

EAPI="2"
NEED_PYTHON="2.5"
SUPPORT_PYTHON_ABIS="1"

inherit distutils flag-o-matic toolchain-funcs

DESCRIPTION="Python Cryptography Toolkit"
HOMEPAGE="http://www.amk.ca/python/code/crypto.html"
SRC_URI="http://www.amk.ca/files/python/crypto/${P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bindist gmp test"

RDEPEND="gmp? ( dev-libs/gmp )"
DEPEND="${RDEPEND}
	test? ( =dev-python/sancho-0.11-r1 )"
RESTRICT_PYTHON_ABIS="3.*"

DOCS="ACKS ChangeLog PKG-INFO README TODO Doc/pycrypt.tex"

src_prepare() {
	use bindist && epatch "${FILESDIR}"/${P}-bindist.patch
	epatch "${FILESDIR}"/${P}-sha256.patch
	epatch "${FILESDIR}"/${P}-sha256-2.patch
	epatch "${FILESDIR}"/${P}-gmp.patch
	epatch "${FILESDIR}"/${P}-uint32.patch
	epatch "${FILESDIR}"/${P}-sancho-package-rename.patch
	epatch "${FILESDIR}"/${P}-2.6_hashlib.patch
	#ARC2 buffer overlow. Bug 258049
	epatch "${FILESDIR}"/${P}-CVE-2009-0544.patch

	epatch "${FILESDIR}"/${P}-caseimport.patch # for case insensitive filesystems
}

src_compile() {
	use gmp \
		&& export USE_GMP=1 \
		|| export USE_GMP=0
	# sha256 hashes occasionally trigger ssp when built with
	# -finline-functions (implied by -O3).
	gcc-specs-ssp && append-flags -fno-inline-functions
	distutils_src_compile
	python_need_rebuild
}

src_test() {
	testing() {
		PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" test.py || die "test failed with Python ${PYTHON_ABI}"
		cd test
		local test
		for test in test_*.py; do
			PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" "${test}" || die "${test} failed with Python ${PYTHON_ABI}"
		done
	}
	python_execute_function testing
}
