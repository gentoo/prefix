# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mako/mako-0.2.5.ebuild,v 1.1 2009/09/07 21:26:16 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="A python templating language."
HOMEPAGE="http://www.makotemplates.org/"
MY_P="Mako-${PV}"
SRC_URI="http://www.makotemplates.org/downloads/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc test"

RDEPEND=""
DEPEND="dev-python/setuptools
	test? ( dev-python/beaker )"
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

src_test() {
	testing() {
		PYTHONPATH="lib:build-${PYTHON_ABI}/lib" "$(PYTHON)" test/alltests.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	use doc && dohtml doc/*html doc/*css
}
