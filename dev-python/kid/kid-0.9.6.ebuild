# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/kid/kid-0.9.6.ebuild,v 1.1 2007/07/17 07:35:25 lucass Exp $

NEED_PYTHON=2.3

inherit distutils

DESCRIPTION="A simple and Pythonic XML template language"
SRC_URI="http://www.kid-templating.org/dist/${PV}/dist/${P}.tar.gz"
HOMEPAGE="http://www.kid-templating.org/"

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="MIT"
SLOT="0"
IUSE="doc examples"

RDEPEND="|| ( >=dev-lang/python-2.5 dev-python/elementtree )"
DEPEND="${RDEPEND}
	>=dev-python/setuptools-0.6_rc6
	doc? ( dev-python/docutils )"

src_test() {
	# We have to move the build folder out of the way to make the tests work
	mv build build.bak
	PYTHONPATH="." "${python}" run_tests.py -x || die "tests failed"
	mv build.bak build
}

src_compile() {
	distutils_src_compile
	use doc && emake -C doc
}

src_install() {
	DOCS="HISTORY RELEASING"
	distutils_src_install

	dobin bin/*

	dodoc doc/*.txt
	use doc && dohtml doc/*.{html,css}

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	elog "Installing dev-python/celementtree may enhance performance."
}
