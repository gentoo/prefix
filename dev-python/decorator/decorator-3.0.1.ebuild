# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/decorator/decorator-3.0.1.ebuild,v 1.4 2009/08/08 00:55:22 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Simplifies the usage of decorators for the average programmer"
HOMEPAGE="http://pypi.python.org/pypi/decorator"
SRC_URI="http://pypi.python.org/packages/source/d/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc"

DEPEND=""
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

DOCS="CHANGES.txt README.txt"

src_test() {
	# multiprocessing module is available only in Python >=2.6, and isn't used anyway.
	sed -i -e '/multiprocessing/d' documentation.py || die
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" documentation.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	if use doc; then
	   dodoc documentation.pdf || die "dodoc pdf doc failed"
	   dohtml documentation.html || die "dohtml html doc failed"
	fi
}

pkg_postinst() {
	python_mod_optimize decorator.py
}

pkg_postrm() {
	python_mod_cleanup
}
