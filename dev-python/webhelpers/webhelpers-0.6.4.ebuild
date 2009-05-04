# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/webhelpers/webhelpers-0.6.4.ebuild,v 1.1 2009/04/27 04:47:33 patrick Exp $

NEED_PYTHON=2.3

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

MY_PN=WebHelpers
MY_P=${MY_PN}-${PV}

DESCRIPTION="A library of helper functions intended to make writing templates in web applications easier."
HOMEPAGE="http://pylonshq.com/WebHelpers/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND=">=dev-python/simplejson-1.4
	>=dev-python/routes-1.8"
DEPEND="${RDEPEND}
	test? ( dev-python/nose dev-python/coverage )
	dev-python/setuptools"

S=${WORKDIR}/${MY_P}

src_test() {
	PYTHONPATH=. "${python}" setup.py nosetests || die "tests failed"
}
