# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pytz/pytz-2009n.ebuild,v 1.1 2009/10/01 03:54:51 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit eutils distutils

DESCRIPTION="World Timezone Definitions for Python"
HOMEPAGE="http://pypi.python.org/pypi/pytz/ http://pytz.sourceforge.net/"
SRC_URI="http://pypi.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

RDEPEND="dev-python/setuptools
	>=sys-libs/timezone-data-${PV}"
DEPEND="${RDEPEND}"
RESTRICT_PYTHON_ABIS="3.*"

DOCS="CHANGES.txt"

src_prepare() {
	# Use timezone-data zoneinfo.
	epatch "${FILESDIR}/${PN}-2009j-zoneinfo.patch"
}

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" pytz/tests/test_tzinfo.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	rm -fr "${ED}"usr/lib*/python*/site-packages/pytz/zoneinfo
}
