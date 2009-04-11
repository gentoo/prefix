# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/nose/nose-0.10.4.ebuild,v 1.9 2009/04/06 18:16:45 armin76 Exp $

inherit distutils eutils

DESCRIPTION="A unittest extension offering automatic test suite discovery and easy test authoring"
HOMEPAGE="http://somethingaboutorange.com/mrl/projects/nose/"
SRC_URI="http://somethingaboutorange.com/mrl/projects/nose/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples test"

RDEPEND="dev-python/setuptools"
DEPEND="${RDEPEND}
	test? ( dev-python/twisted )"

src_unpack() {
	distutils_src_unpack

	# Disable tests that access the network
	epatch "${FILESDIR}/${PN}-0.10.0-tests-nonetwork.patch"
}

src_install() {
	DOCS="AUTHORS"
	distutils_src_install --install-data "${EPREFIX}"/usr/share

	use doc && dohtml doc/*

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	# Create the missing empty directory, that's required for tests to pass
	if [[ ! -e "${S}"/functional_tests/support/empty ]]; then
		mkdir "${S}"/functional_tests/support/empty
	fi
	PYTHONPATH=. "${python}" setup.py test || die "test failed"
}
