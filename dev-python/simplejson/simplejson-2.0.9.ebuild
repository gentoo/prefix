# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/simplejson/simplejson-2.0.9.ebuild,v 1.1 2009/04/03 09:43:10 patrick Exp $

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DESCRIPTION="A simple, fast, complete, correct and extensible JSON encoder and decoder."
HOMEPAGE="http://undefined.org/python/#simplejson"
SRC_URI="http://cheeseshop.python.org/packages/source/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="doc test"

RDEPEND="<dev-lang/python-2.6"
DEPEND="dev-python/setuptools
		${RDEPEND}"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/*
	fi
}

src_test() {
	PYTHONPATH=. "${python}" simplejson/tests/__init__.py || die "test failed"
}
