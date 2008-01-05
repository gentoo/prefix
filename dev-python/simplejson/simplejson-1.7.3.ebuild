# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/simplejson/simplejson-1.7.3.ebuild,v 1.1 2008/01/04 17:23:34 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

KEYWORDS="~amd64 ~x86 ~x86-macos"

DESCRIPTION="A simple, fast, complete, correct and extensible JSON encoder and decoder."
HOMEPAGE="http://undefined.org/python/#simplejson"
SRC_URI="http://cheeseshop.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="test"

DEPEND="test? ( dev-python/nose )
	dev-python/setuptools"
RDEPEND=""

src_install() {
	distutils_src_install
	dohtml -r docs/*
}

src_test() {
	PYTHONPATH=. "${python}" setup.py test || die "test failed"
}
