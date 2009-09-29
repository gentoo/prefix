# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/nose/nose-0.11.1.ebuild,v 1.4 2009/09/27 18:48:09 nixnut Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="A unittest extension offering automatic test suite discovery and easy test authoring"
HOMEPAGE="http://somethingaboutorange.com/mrl/projects/nose/"
SRC_URI="http://somethingaboutorange.com/mrl/projects/nose/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples test"

# dev-python/setuptools is used at run time
RDEPEND="dev-python/setuptools"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx )
	test? ( dev-python/twisted )"

RESTRICT_PYTHON_ABIS="3*"

src_prepare() {
	distutils_src_prepare

	# Disable tests and doc features that access the network
	epatch \
		"${FILESDIR}/${PN}-0.10.0-tests-nonetwork.patch" \
		"${FILESDIR}/${PN}-0.11.0-disable_intersphinx.patch"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		cd doc
		mkdir -p .build/html .build/doctrees
		sphinx-build . html || die "building docs failed"
	fi
}

src_test() {
	# Create the missing empty directory, that's required for tests to pass
	if [[ ! -e "${S}"/functional_tests/support/empty ]]; then
		mkdir "${S}"/functional_tests/support/empty
	fi
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" setup.py test
	}
	python_execute_function testing
}

src_install() {
	DOCS="AUTHORS"
	distutils_src_install --install-data "${EPREFIX}"/usr/share

	use doc && dohtml -r -A txt doc/html/*

	if use examples; then
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
