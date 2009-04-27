# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/werkzeug/werkzeug-0.5.ebuild,v 1.1 2009/04/25 15:44:21 patrick Exp $

NEED_PYTHON="2.4"

inherit distutils

MY_P="Werkzeug-${PV}"

DESCRIPTION="Collection of various utilities for WSGI applications"
HOMEPAGE="http://werkzeug.pocoo.org/"
SRC_URI="http://pypi.python.org/packages/source/W/Werkzeug/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"

RDEPEND=""
DEPEND=">=dev-python/setuptools-0.6_rc5
	test? ( dev-python/py
		dev-python/lxml
		dev-python/nose
		dev-python/simplejson )"

S="${WORKDIR}/${MY_P}"

src_install() {
	DOCS="CHANGES"
	distutils_src_install
}

src_test() {
	distutils_python_version
	make test || die "tests failed"
}
