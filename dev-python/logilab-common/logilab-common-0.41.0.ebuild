# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/logilab-common/logilab-common-0.41.0.ebuild,v 1.1 2009/06/04 13:01:39 idl0r Exp $

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

PYTHON_MODNAME="logilab"
# Extra documentation (html/pdf) needs some love

src_unpack() {
	distutils_src_unpack

	epatch "${FILESDIR}/${P}-remove-broken-tests.patch"
}

src_test() {
	python_version

	# Install temporarily.
	local tpath="${T}/test"
	local lpath="${tpath}/lib/python"

	# setuptools would fail if the directory doesn't exist.
	mkdir -p "${lpath}" || die

	# We also have to add ${lpath} to PYTHONPATH else the installation would
	# fail.
	PYTHONPATH="${lpath}" ${python} setup.py install --home="${tpath}" || \
		die "test copy failed"

	# Get a rid of precompiled files to ensure we run our _modified_ tests
	find ${lpath} -type f -name '*.pyc' -exec rm {} ';'

	# Remove a botched tests.
	# To support test w/o setuptools.
	if [[ -d "${lpath}/${PN/-//}" ]]; then
		pushd "${lpath}/${PN/-//}" >/dev/null || die
	else
		pushd "${lpath}/${P/-/_}-py${PYVER}.egg/${PN/-//}" >/dev/null || die
	fi

	# Bug 223079
	if ! has userpriv ${FEATURES}; then
		rm test/unittest_fileutils.py || die
	fi

	popd >/dev/null || die

	# It picks up the tests relative to the current dir, so cd in. Do
	# not cd in too far though (to logilab/common for example) or some
	# relative/absolute module location tests fail.
	pushd "${lpath}" >/dev/null || die
	PYTHONPATH="${lpath}" ${python} "${tpath}/bin/pytest" -v || die "tests failed"
	popd >/dev/null || die
}

src_install() {
	distutils_src_install

	doman doc/pytest.1 || die "doman failed"

	# Remove unittests since they're just needed during build-time
	rm -rf "${ED}/$(python_get_sitedir)/${PN/-//}/test" || die
}
