# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mako/mako-0.1.10-r1.ebuild,v 1.1 2008/07/14 03:27:16 antarus Exp $

inherit distutils

DESCRIPTION="A python templating language."
HOMEPAGE="http://www.makotemplates.org/"
MY_P="Mako-${PV}"
SRC_URI="http://www.makotemplates.org/downloads/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc test"

DEPEND="dev-python/setuptools"
RDEPEND=""
S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install
	use doc && dohtml doc/*html doc/*css
}

src_test() {
	PYTHONPATH="./lib" "${python}" test/alltests.py || die "tests failed"
}
