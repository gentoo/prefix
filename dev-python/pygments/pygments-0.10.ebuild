# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygments/pygments-0.10.ebuild,v 1.2 2008/05/27 18:40:03 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

MY_PN="Pygments"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Pygments is a syntax highlighting package written in Python."
HOMEPAGE="http://pygments.org/"
SRC_URI="http://cheeseshop.python.org/packages/source/P/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux"
SLOT="0"
IUSE="doc"

DEPEND="dev-python/setuptools"
RDEPEND=""

S="${WORKDIR}/${MY_P}"
DOCS="CHANGES"

src_unpack() {
	distutils_src_unpack

	# Make lexer recognize ebuilds as bash input
	sed -i \
		-e "/\(BashLexer\|aliases\)/s/\('sh'\)/\1, 'ebuild'/" \
		-e "/\(BashLexer\|filenames\)/s/\('\*\.sh'\)/\1, '*.ebuild'/" \
		${PN}/lexers/_mapping.py ${PN}/lexers/other.py ||\
		die "sed failed."
}

src_install(){
	distutils_src_install
	use doc && dohtml -r docs/build/
}

src_test() {
	PYTHONPATH=. "${python}" tests/run.py || die "tests failed"
}
