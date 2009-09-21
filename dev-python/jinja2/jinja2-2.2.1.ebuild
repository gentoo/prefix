# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/jinja2/jinja2-2.2.1.ebuild,v 1.3 2009/09/17 20:57:29 volkmar Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="Jinja2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A small but fast and easy to use stand-alone template engine written in pure python."
HOMEPAGE="http://jinja.pocoo.org/"
SRC_URI="http://pypi.python.org/packages/source/J/${MY_PN}/${MY_P}.tar.gz"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
SLOT="0"
IUSE="doc examples i18n test"

CDEPEND="dev-python/setuptools"
DEPEND="${CDEPEND}
	doc? ( >=dev-python/docutils-0.4
		   >=dev-python/sphinx-0.3 )
	test? ( dev-python/nose )"
RDEPEND="${CDEPEND}
	i18n? ( >=dev-python/Babel-0.9.3 )"
RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

DISTUTILS_GLOBAL_OPTIONS=("--with-speedups")
DOCS="CHANGES"

src_compile(){
	distutils_src_compile

	if use doc; then
		cd "${S}/docs"
		PYTHONPATH=.. emake html || die "Building of documentation failed"
	fi
}

src_test(){
	testing() {
		pushd tests > /dev/null
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" nosetests-${PYTHON_ABI} -v || return 1
		popd > /dev/null
	}
	python_execute_function testing
}

src_install(){
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/* || die "Installation of documentation failed"
	fi

	if use examples; then
		# Eliminate .pyc files going into /usr/share
	    find examples -name "*.pyc" -print0 | xargs -0 rm -fr

		insinto "/usr/share/doc/${PF}"
		doins -r examples || die "Failed to install examples"
	fi
}
