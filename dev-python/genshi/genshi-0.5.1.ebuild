# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/genshi/genshi-0.5.1.ebuild,v 1.5 2008/11/16 17:46:16 maekke Exp $

NEED_PYTHON=2.3

inherit distutils

MY_P="Genshi-${PV}"

DESCRIPTION="Python toolkit for stream-based generation of output for the web."
HOMEPAGE="http://genshi.edgewall.org/"
SRC_URI="ftp://ftp.edgewall.com/pub/genshi/${MY_P}.tar.bz2"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples"

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install

	if use doc ; then
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
