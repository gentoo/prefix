# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.8.6.ebuild,v 1.2 2009/07/10 18:05:44 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.6"

inherit distutils

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=x11-libs/cairo-1.8.6"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( dev-python/sphinx )"

PYTHON_MODNAME="cairo"
DOCS="AUTHORS NEWS README"

src_prepare() {
	# Don't run py-compile.
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		cairo/Makefile.in || die "sed in cairo/Makefile.in failed"
}

src_configure() {
	if use doc; then
		econf
	fi
}

src_compile() {
	distutils_src_compile

	if use doc; then
		emake html || die "emake html failed"
	fi
}

src_test() {
	cd test
	PYTHONPATH="$(ls -d ${S}/build/lib.*)" "${python}" test.py || die "tests failed"
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/.build/html/ || die "dohtml -r doc/.build/html/ failed"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
}
