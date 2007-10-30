# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/genshi/genshi-0.4.4.ebuild,v 1.1 2007/10/29 13:02:08 jokey Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

MY_P=Genshi-${PV}

DESCRIPTION="Python toolkit for stream-based generation of output for the web"
HOMEPAGE="http://genshi.edgewall.org/"
SRC_URI="ftp://ftp.edgewall.com/pub/genshi/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="doc examples"

DEPEND=""
RDEPEND=">=dev-python/setuptools-0.6_rc3"

S="${WORKDIR}/${MY_P}"
DOCS="INSTALL.txt UPGRADE.txt"

src_install() {
	distutils_src_install

	if use doc; then
		dodoc doc/*.txt
		dohtml -r doc/*
	fi

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	"${python}" setup.py test || die "test failed"
}
