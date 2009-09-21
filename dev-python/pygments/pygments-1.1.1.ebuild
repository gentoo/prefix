# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygments/pygments-1.1.1.ebuild,v 1.2 2009/09/17 12:26:06 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="Pygments"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Pygments is a syntax highlighting package written in Python."
HOMEPAGE="http://pygments.org/"
SRC_URI="http://pypi.python.org/packages/source/P/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
SLOT="0"
IUSE="doc test"

DEPEND="test? ( media-fonts/ttf-bitstream-vera
		dev-python/nose	)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"
DOCS="CHANGES"

src_test() {
	testing() {
		# A future version of dev-python/nose will support Python 3.
		[[ "${PYTHON_ABI}" == 3* ]] && return

		"$(PYTHON)" tests/run.py
	}
	python_execute_function testing
}

src_install(){
	distutils_src_install
	use doc && dohtml -r docs/build/
}
