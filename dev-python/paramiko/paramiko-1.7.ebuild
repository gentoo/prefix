# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/paramiko/paramiko-1.7.ebuild,v 1.1 2007/03/24 16:37:48 lucass Exp $

NEED_PYTHON=2.3

inherit distutils eutils

DESCRIPTION="SSH2 implementation for Python"
HOMEPAGE="http://www.lag.net/paramiko/"
SRC_URI="http://www.lag.net/paramiko/download/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="doc examples"

RDEPEND=">=dev-python/pycrypto-1.9_alpha6"
DEPEND="${RDEPEND}
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-1.6.3-no-setuptools.patch"
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
	"${python}" test.py || die "tests failed"
}
