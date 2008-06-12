# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/paramiko/paramiko-1.7.2.ebuild,v 1.5 2008/02/15 16:58:40 jer Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils eutils

DESCRIPTION="SSH2 implementation for Python"
HOMEPAGE="http://www.lag.net/paramiko/"
SRC_URI="http://www.lag.net/paramiko/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="doc examples"

RDEPEND=">=dev-python/pycrypto-1.9_alpha6"
DEPEND="${RDEPEND}"

src_unpack() {
	distutils_src_unpack

	epatch "${FILESDIR}"/${PN}-1.6.3-no-setuptools.patch
	epatch "${FILESDIR}"/${P}-tests_cleanup.patch
}

src_install() {
	distutils_src_install

	use doc && dohtml -r docs/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r demos
	fi
}

src_test() {
	"${python}" test.py --verbose || die "tests failed"
}
