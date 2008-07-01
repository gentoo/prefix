# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyopenssl/pyopenssl-0.6-r1.ebuild,v 1.3 2007/02/13 13:19:03 vapier Exp $

EAPI="prefix"

inherit distutils

MY_P=${P/openssl/OpenSSL}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Python interface to the OpenSSL library"
HOMEPAGE="http://pyopenssl.sourceforge.net/"
SRC_URI="mirror://sourceforge/pyopenssl/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris"
IUSE="doc"

RDEPEND="dev-lang/python
	>=dev-libs/openssl-0.9.6g"
DEPEND="${RDEPEND}
	doc? ( >=dev-tex/latex2html-2002.2 )"

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

src_install() {
	distutils_src_install

	if use doc; then
		dohtml "${S}"/doc/html/*
		dodoc "${S}"/doc/pyOpenSSL.*
	fi

	# install examples
	docinto examples
	dodoc "${S}"/examples/*
	docinto examples/simple
	dodoc "${S}"/examples/simple/*
}
