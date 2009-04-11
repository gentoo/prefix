# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-dateutil/python-dateutil-1.4.1-r1.ebuild,v 1.1 2009/01/20 13:56:28 neurogeek Exp $

EAPI=2
NEED_PYTHON=2.3
inherit distutils

DESCRIPTION="dateutil datetime math and logic library for python"
HOMEPAGE="http://labix.org/python-dateutil"
SRC_URI="http://labix.org/download/python-dateutil/${P}.tar.gz"

LICENSE="PSF-2.3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DOCS="NEWS README"

DEPEND=">=dev-python/setuptools-0.6_rc7-r1
	      sys-libs/timezone-data"
RDEPEND=""

PYTHON_MODNAME=dateutil

src_prepare() {
	epatch "${FILESDIR}"/${P}-locale.patch
	# use zoneinfo in /usr/share/zoneinfo
	sed -i -e 's/zoneinfo.gettz/gettz/g' test.py || die
}

src_test() {
	PYTHONPATH=build/lib "${python}" test.py || die
}

src_install() {
	distutils_src_install
	insinto /usr/share/doc/${PF}/examples
	doins example.py sandbox/*.py
	rm -f "${ED}"/usr/lib*/python*/site-packages/dateutil/zoneinfo/*.tar.*
}
