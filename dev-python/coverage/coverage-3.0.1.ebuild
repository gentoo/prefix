# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/coverage/coverage-3.0.1.ebuild,v 1.2 2009/09/05 18:37:05 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Measures code coverage during Python execution"
HOMEPAGE="http://nedbatchelder.com/code/modules/coverage.html"
SRC_URI="http://pypi.python.org/packages/source/c/coverage/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND=""
DEPEND="dev-python/setuptools
	test? ( >=dev-python/nose-0.10.3 )"
RESTRICT_PYTHON_ABIS="3.*"

PYTHON_MODNAME="coverage"

src_test() {
	testing() {
		"$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" nosetests
	}
	python_execute_function testing
}
