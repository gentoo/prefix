# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pysqlite/pysqlite-2.3.1.ebuild,v 1.9 2006/10/20 20:36:05 kloeri Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="Python wrapper for the local database Sqlite"
SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PV:0:3}/${PV}/pysqlite-${PV}.tar.gz"
HOMEPAGE="http://initd.org/tracker/pysqlite/"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
LICENSE="pysqlite"
SLOT="2"
IUSE=""

DEPEND=">=dev-lang/python-2.3
	>=dev-db/sqlite-3.1"

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
	distutils_src_install

	mv "${ED}"/usr/pysqlite2-doc/* "${ED}"/usr/share/doc/${PF}
	rm -rf "${ED}"/usr/pysqlite2-doc
}

src_test() {
	cd build/lib*
	# tests use this as a nonexistant file
	addpredict /foo/bar
	PYTHONPATH=. "${python}" -c \
		"from pysqlite2.test import test;import sys;sys.exit(test())" \
		|| die "test failed"
}
