# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyxml/pyxml-0.8.4-r2.ebuild,v 1.10 2009/09/23 17:47:04 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_P=${P/pyxml/PyXML}

DESCRIPTION="A collection of libraries to process XML with Python"
HOMEPAGE="http://pyxml.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="PYTHON"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples"

DEPEND=">=dev-libs/expat-1.95.6"
RDEPEND="${DEPEND}"
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

DOCS="ANNOUNCE CREDITS doc/*.txt"
PYTHON_MODNAME="_xmlplus"

src_prepare(){
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-python-2.6.patch"
}

src_compile() {
	local myconf

	# if you want to use 4Suite, then their XSLT/XPATH is
	# better according to the docs
	if has_version "dev-python/4suite"; then
		myconf="--without-xslt --without-xpath"
	fi

	# use the already-installed shared copy of libexpat
	distutils_src_compile --with-libexpat="${EPREFIX}"/usr ${myconf}
}
src_test() {
	cd test
	testing() {
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" regrtest.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	doman doc/man/*
	if use doc; then
		dohtml -A api,web -r doc/*
		insinto /usr/share/doc/${PF} && doins doc/*.tex
	fi
	use examples && cp -r demo "${ED}"/usr/share/doc/${PF}
}
