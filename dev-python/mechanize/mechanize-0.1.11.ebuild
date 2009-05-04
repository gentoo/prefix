# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mechanize/mechanize-0.1.11.ebuild,v 1.3 2009/04/26 19:26:56 ranger Exp $

NEED_PYTHON=2.4

inherit distutils

DESCRIPTION="Stateful programmatic web browsing in Python"
HOMEPAGE="http://wwwsearch.sourceforge.net/mechanize/"
SRC_URI="http://wwwsearch.sourceforge.net/${PN}/src/${P}.tar.gz"

LICENSE="|| ( BSD ZPL )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=dev-python/clientform-0.2.7"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# use distutils instead of setuptools
	sed -i \
		-e 's/not hasattr(sys, "version_info")/1/' \
		setup.py || die "sed in setup.py failed"

	# We don't run coverage tests or functional_tests
	# which access the network, just doctests and unit tests
	sed -i \
		-e '/import coverage/d' \
		test.py || die "sed in test.py failed"
}

src_install() {
	DOCS="0.1-changes.txt"
	# remove to prevent distutils_src_install from installing it
	dohtml *.html
	rm README.html*

	distutils_src_install
}

src_test() {
	PYTHONPATH=build/lib/ "${python}" test.py || die "tests failed"
}
