# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/coverage/coverage-2.85.ebuild,v 1.3 2009/05/02 16:59:23 nixnut Exp $

inherit distutils

DESCRIPTION="Measures code coverage during Python execution"
HOMEPAGE="http://nedbatchelder.com/code/modules/coverage.html"
SRC_URI="http://nedbatchelder.com/code/modules/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"
RDEPEND=""
DEPEND="${RDEPEND}
	test? ( >=dev-python/nose-0.10.3 )"

PYTHON_MODNAME="coverage.py"

src_test() {
	${python} setup.py nosetests || die
}
