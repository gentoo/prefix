# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sphinx/sphinx-0.6.2.ebuild,v 1.4 2009/08/12 02:03:49 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="Sphinx"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Tool to create documentation for Python projects"
HOMEPAGE="http://sphinx.pocoo.org/"
SRC_URI="http://pypi.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="doc test"

RDEPEND=">=dev-python/pygments-0.8
	>=dev-python/jinja2-2.1
	>=dev-python/docutils-0.4"

DEPEND="${RDEPEND}
	dev-python/setuptools
	test? ( dev-python/nose )"

RESTRICT_PYTHON_ABIS="3*"

S="${WORKDIR}/${MY_P}"

src_compile() {
	DOCS="CHANGES"
	distutils_src_compile

	if use doc; then
		cd doc
		PYTHONPATH="../" emake \
			SPHINXBUILD="${python} ../sphinx-build.py" \
			html || die "making docs failed"
	fi
}

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" nosetests
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -A txt -r doc/_build/html/* || die
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	# Generating the Grammar pickle to avoid on the fly generation causing sandbox violations (bug #266015)
	generation_of_grammar_pickle() {
		"$(PYTHON)" -c "from sphinx.pycode.pgen2.driver import load_grammar; load_grammar('${EROOT}$(python_get_sitedir)/sphinx/pycode/Grammar.txt')" \
		|| die "Generation of grammar pickle failed"
	}
	python_execute_function --action-message 'Generation of Grammar pickle with Python ${PYTHON_ABI}...' generation_of_grammar_pickle
}

pkg_postrm() {
	distutils_pkg_postrm

	deletion_of_grammar_pickle() {
		rm "${EROOT}$(python_get_sitedir)/sphinx/pycode"/Grammar*.pickle
	}
	python_execute_function --action-message 'Deletion of Grammar pickle with Python ${PYTHON_ABI}...' deletion_of_grammar_pickle
}
