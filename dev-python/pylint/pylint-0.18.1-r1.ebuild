# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pylint/pylint-0.18.1-r1.ebuild,v 1.1 2009/09/20 17:58:01 neurogeek Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="a tool to check if a Python module satisfies a coding standard"
HOMEPAGE="http://www.logilab.org/projects/pylint/"
SRC_URI="ftp://ftp.logilab.org/pub/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="doc examples test tk"

DEPEND=">=dev-python/logilab-common-0.38
	>=dev-python/astng-0.19.0"
RDEPEND="${DEPEND}
	dev-lang/python[tk?]"
RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-utils.py.patch"
}

src_test() {
	testing() {
		local lpath="${T}/test/lib/python"
		local tpath=""

		rm -fr "${lpath}"

		# Create testdir and copy pylint into it for testing purpose.
		mkdir -p "${lpath}/logilab" || die
		PYTHONPATH="${lpath}" "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --home="${T}/test" || die "test copy failed"

		# To support test w/o setuptools.
		if [[ -d "${lpath}/${PN}" ]]; then
			tpath="${lpath}/${PN}"
		else
			tpath="${lpath}/${P}-py${PYTHON_ABI}.egg/${PN}"
		fi

		# Copy pylint unittest and logilab-{common,astng} into our temporary test
		# dir.
		cp -r test/ ${tpath} || die "copy tests failed"
		cp -r "$(python_get_sitedir)/logilab/"{common,astng} "${lpath}/logilab" || die "copying logilab-{common,astng} failed!"

		pushd "${tpath}" >/dev/null || die
		PYTHONPATH="${lpath}" pytest -v || die "tests failed"
		popd >/dev/null || die
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	doman man/{pylint,pyreverse}.1 || die "doman failed"
	dodoc doc/FAQ.txt || die "dodoc failed"

	if use doc; then
		dodoc doc/*.txt || die "dodoc failed"
	fi

	if use examples; then
		docinto examples
		dodoc examples/* || die "dodoc failed"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	if ! built_with_use dev-lang/python tk; then
		ewarn "dev-lang/python has been built without tk support,"
		ewarn "${PN}-gui doesn't work without Tkinter so if you really need it"
		ewarn "re-install dev-lang/python with tk useflag enabled."
	fi
}
