# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycurl/pycurl-7.19.0.ebuild,v 1.1 2008/11/04 04:18:17 dragonheart Exp $

inherit distutils

DESCRIPTION="python binding for curl/libcurl"
HOMEPAGE="http://pycurl.sourceforge.net/"
SRC_URI="http://pycurl.sourceforge.net/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="examples"

DEPEND=">=net-misc/curl-7.18.1"

PYTHON_MODNAME="curl"

src_install() {
	sed -i \
		-e "/data_files=/d" \
		setup.py || die "sed in setup.py failed."

	distutils_src_install

	dohtml -r doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
		doins -r tests
	fi
}

src_test() {
	emake test || die "test failed"
}
