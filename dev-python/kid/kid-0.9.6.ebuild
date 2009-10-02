# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/kid/kid-0.9.6.ebuild,v 1.2 2009/10/01 23:12:25 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.5"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="A simple and Pythonic XML template language"
SRC_URI="http://www.kid-templating.org/dist/${PV}/dist/${P}.tar.gz"
HOMEPAGE="http://www.kid-templating.org/"

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="MIT"
SLOT="0"
IUSE="doc examples"

RDEPEND=""
DEPEND=">=dev-python/setuptools-0.6_rc6
	doc? ( dev-python/docutils )"
RESTRICT_PYTHON_ABIS="2.4 3.*"

DOCS="HISTORY RELEASING"

src_compile() {
	distutils_src_compile
	use doc && emake -C doc
}

src_test() {
	testing() {
		PYTHONPATH="." "$(PYTHON)" run_tests.py -x
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	dobin bin/*

	dodoc doc/*.txt
	use doc && dohtml doc/*.{html,css}

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
