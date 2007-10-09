# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/nose/nose-0.10.0_beta1.ebuild,v 1.2 2007/09/14 09:59:11 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.2

inherit distutils eutils

MY_PV="${PV/_beta/b}"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="A unittest extension offering automatic test suite discovery and easy test authoring"
HOMEPAGE="http://somethingaboutorange.com/mrl/projects/nose/"
SRC_URI="http://somethingaboutorange.com/mrl/projects/nose/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86 ~x86-macos"
SLOT="0"
IUSE="doc examples twisted"

RDEPEND="dev-python/setuptools
	twisted? ( dev-python/twisted )"
DEPEND="${RDEPEND}
	doc? ( dev-python/docutils )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	distutils_src_unpack

	# If twisted is in USE, disable twisted tests that access the network
	# else remove nose.twistedtools and related tests
	use twisted && epatch "${FILESDIR}/${P}-tests-nonetwork.patch"
	use twisted || rm nose/twistedtools.py unit_tests/test_twisted*
}

src_compile() {
	distutils_src_compile
	if use doc ; then
		PYTHONPATH=. scripts/mkindex.py
	fi
}

src_install() {
	DOCS="AUTHORS NEWS"
	distutils_src_install --install-data "${EPREFIX}"/usr/share

	use doc && dohtml index.html

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	PYTHONPATH=. "${python}" setup.py test || die "test failed"
}
