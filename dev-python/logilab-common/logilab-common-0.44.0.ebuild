# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/logilab-common/logilab-common-0.44.0.ebuild,v 1.1 2009/08/25 14:40:26 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils python

DESCRIPTION="useful miscellaneous modules used by Logilab projects"
HOMEPAGE="http://www.logilab.org/projects/common/"
SRC_URI="ftp://ftp.logilab.org/pub/common/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="test"

DEPEND="test? ( dev-python/egenix-mx-base )"
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

PYTHON_MODNAME="logilab"
# Extra documentation (html/pdf) needs some love

pkg_setup() {
	# Tests using dev-python/psycopg are skipped when dev-python/psycopg isn't installed.
	if use test && has_version dev-python/psycopg && ! has_version dev-python/psycopg[mxdatetime]; then
		die "dev-python/psycopg should be installed with USE=\"mxdatetime\""
	fi
}

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-0.41.0-remove-broken-tests.patch"
}

src_test() {
	testing() {
		# Install temporarily.
		local tpath="${T}/test-${PYTHON_ABI}"
		local lpath="${tpath}/lib/python"

		# setuptools would fail if the directory doesn't exist.
		mkdir -p "${lpath}" || die

		# We also have to add ${lpath} to PYTHONPATH else the installation would
		# fail.
		PYTHONPATH="${lpath}" "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --home="${tpath}" || die "test copy failed"

		# Get a rid of precompiled files to ensure we run our _modified_ tests
		find ${lpath} -type f -name '*.pyc' -exec rm {} ';'

		# Remove a botched tests.
		# To support test w/o setuptools.
		if [[ -d "${lpath}/${PN/-//}" ]]; then
			pushd "${lpath}/${PN/-//}" >/dev/null || die
		else
			pushd "${lpath}/${P/-/_}-py${PYTHON_ABI}.egg/${PN/-//}" >/dev/null || die
		fi

		# Bug 223079
		if [[ "${EUID}" -eq 0 ]]; then
			rm test/unittest_fileutils.py || die
		fi

		popd >/dev/null || die

		# It picks up the tests relative to the current dir, so cd in. Do
		# not cd in too far though (to logilab/common for example) or some
		# relative/absolute module location tests fail.
		pushd "${lpath}" >/dev/null || die
		PYTHONPATH="${lpath}" "$(PYTHON)" "${tpath}/bin/pytest" -v || die "tests failed"
		popd >/dev/null || die
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	doman doc/pytest.1 || die "doman failed"

	# Remove unittests since they're just needed during build-time
	rm -rf "${ED}"usr/lib*/python*/site-packages/${PN/-//}/test || die
}
