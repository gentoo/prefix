# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pysqlite/pysqlite-2.3.3.ebuild,v 1.1 2007/05/05 09:53:10 lucass Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

DESCRIPTION="Python wrapper for the local database Sqlite"
SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PV:0:3}/${PV}/pysqlite-${PV}.tar.gz"
HOMEPAGE="http://initd.org/tracker/pysqlite/"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
LICENSE="pysqlite"
SLOT="2"
IUSE="examples"

DEPEND=">=dev-db/sqlite-3.1"

src_unpack() {
	unpack ${A}

	# setup.cfg has hardcoded non-prefix paths, kill them
	cd "${S}"
	sed -i \
		-e '/^include_dirs=/d' \
		-e '/^library_dirs=/d' \
		setup.cfg
}

src_install() {
	DOCS="doc/usage-guide.txt"
	distutils_src_install

	rm -rf "${ED}"/usr/pysqlite2-doc

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r doc/code
	fi
}

src_test() {
	cd build/lib*
	# tests use this as a nonexistant file
	addpredict /foo/bar
	PYTHONPATH=. "${python}" -c \
		"from pysqlite2.test import test;import sys;sys.exit(test())" \
		|| die "test failed"
}
