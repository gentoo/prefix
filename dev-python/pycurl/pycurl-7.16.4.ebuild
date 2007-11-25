# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycurl/pycurl-7.16.4.ebuild,v 1.8 2007/10/08 08:45:39 tgall Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="python binding for curl/libcurl"
HOMEPAGE="http://pycurl.sourceforge.net/"
SRC_URI="http://pycurl.sourceforge.net/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos"
IUSE="examples"

DEPEND=">=net-misc/curl-7.16.2"

PYTHON_MODNAME="curl"

src_test() {
	make test || die "test failed"
}

src_install() {
	DOCS="TODO"

	sed -e '/data_files=/d' -i setup.py

	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
		doins -r tests
	fi

	dohtml -r doc/*
}
