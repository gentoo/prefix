# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyxml/pyxml-0.8.4-r1.ebuild,v 1.9 2008/02/24 00:06:52 dev-zero Exp $

EAPI="prefix"

inherit python distutils

MY_P=${P/pyxml/PyXML}

DESCRIPTION="A collection of libraries to process XML with Python"
HOMEPAGE="http://pyxml.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="PYTHON"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris"
IUSE="doc examples"

DEPEND=">=dev-libs/expat-1.95.6"

S=${WORKDIR}/${MY_P}

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

src_install() {
	DOCS="ANNOUNCE CREDITS doc/*.txt"
	distutils_src_install

	doman doc/man/*
	if use doc; then
		dohtml -A api,web -r doc/*
		insinto /usr/share/doc/${PF} && doins doc/*.tex
	fi
	use examples && cp -r demo "${ED}"/usr/share/doc/${PF}
}

src_test() {
	cd test
	PYTHONPATH="$(ls -d ../build/lib.*)" "${python}" regrtest.py \
		|| die "tests failed"
}
