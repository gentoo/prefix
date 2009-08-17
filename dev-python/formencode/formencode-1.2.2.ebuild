# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/formencode/formencode-1.2.2.ebuild,v 1.1 2009/08/16 23:30:42 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="FormEncode"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HTML form validation, generation and conversion package."
HOMEPAGE="http://formencode.org/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="PSF-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc test"

DEPEND="dev-python/setuptools
	test? ( dev-python/nose )"
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils_src_prepare

	# Avoid test failure when dev-python/formencode isn't already installed.
	sed -e "/pkg_resources/d" -i tests/__init__.py
}

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" LC_ALL="C" nosetests-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		cd "${S}"
		dodoc docs/*.txt

		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
