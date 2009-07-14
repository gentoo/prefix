# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/decorator/decorator-3.0.1.ebuild,v 1.1 2009/03/27 11:41:12 bicatali Exp $

inherit distutils

DESCRIPTION="Simplifies the usage of decorators for the average programmer"
HOMEPAGE="http://pypi.python.org/pypi/decorator"
SRC_URI="http://pypi.python.org/packages/source/d/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc"

DOCS="CHANGES.txt README.txt"

src_test() {
	# multiprocessing only in python-2.6 and above, and not use anyway
	sed -i -e '/multiprocessing/d' documentation.py || die
	PYTHONPATH=build/lib "${python}" documentation.py || die "tests failed"
}

src_install() {
	distutils_src_install
	if use doc;then
	   dodoc documentation.pdf || die "dodoc pdf doc failed"
	   dohtml documentation.html || die "dohtml html doc failed"
	fi
}
