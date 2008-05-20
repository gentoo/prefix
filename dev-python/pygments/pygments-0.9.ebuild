# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-python/pygments/pygments-0.9.ebuild,v 1.6 2007/12/22 18:55:33 nixnut Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit eutils distutils

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

S="${WORKDIR}/${MY_P}"
DOCS="CHANGES"

src_unpack() {
	distutils_src_unpack

	# Gentoo patches to make lexer recognize ebuilds as bash input
	epatch "${FILESDIR}/${PN}-0.8-other.py-ebuild.patch" || die "Patch failed"
	epatch "${FILESDIR}/${PN}-0.8-_mapping.py-ebuild.patch" || die "Patch failed"
}

src_install(){
	distutils_src_install
	use doc && dohtml -r docs/build/
}

src_test() {
	PYTHONPATH=. "${python}" tests/run.py || die "tests failed"
}
