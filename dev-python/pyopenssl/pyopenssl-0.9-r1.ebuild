# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyopenssl/pyopenssl-0.9-r1.ebuild,v 1.2 2009/08/05 18:42:20 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

MY_P=${P/openssl/OpenSSL}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Python interface to the OpenSSL library"
HOMEPAGE="http://pyopenssl.sourceforge.net/"
SRC_URI="mirror://sourceforge/pyopenssl/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/openssl-0.9.6g"
DEPEND="${RDEPEND}
	doc? ( >=dev-tex/latex2html-2002.2 )"

RESTRICT_PYTHON_ABIS="3*"

src_prepare() {
	epatch "${FILESDIR}/${P}-tests.patch"
}

src_compile() {
	distutils_src_compile
	if use doc; then
		addwrite /var/cache/fonts
		# This one seems to be unnecessary with a recent tetex, but
		# according to bugs it was definitely necessary in the past,
		# so leaving it in.
		addwrite /usr/share/texmf/fonts/pk

		cd "${S}"/doc
		make html ps dvi
	fi
}

src_test() {
	test_package() {
		pushd test > /dev/null
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" test_crypto.py || die "test_crypto.py failed"
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" test_ssl.py || die "test_ssl.py failed"
		popd > /dev/null
	}
	python_execute_function test_package
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml "${S}"/doc/html/*
		dodoc "${S}"/doc/pyOpenSSL.*
	fi

	# Install examples
	docinto examples
	dodoc "${S}"/examples/*
	docinto examples/simple
	dodoc "${S}"/examples/simple/*
}

pkg_postinst() {
	python_mod_optimize OpenSSL
}

pkg_postrm() {
	python_mod_cleanup OpenSSL
}
