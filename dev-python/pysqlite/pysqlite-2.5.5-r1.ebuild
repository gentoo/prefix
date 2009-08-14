# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pysqlite/pysqlite-2.5.5-r1.ebuild,v 1.2 2009/08/05 18:47:05 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Python wrapper for the local database Sqlite"
#SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PV:0:3}/${PV}/pysqlite-${PV}.tar.gz"
SRC_URI="http://oss.itsystementwicklung.de/download/pysqlite/${PV:0:3}/${PV}/pysqlite-${PV}.tar.gz"
HOMEPAGE="http://pysqlite.org/"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
LICENSE="pysqlite"
SLOT="2"
IUSE="examples"

DEPEND=">=dev-db/sqlite-3.1"
RDEPEND=${DEPEND}

RESTRICT_PYTHON_ABIS="3*"

PYTHON_MODNAME="pysqlite2"

src_prepare() {
	distutils_src_prepare
	# Don't install pysqlite2.test.
	sed -i -e 's/, "pysqlite2.test"//' \
		setup.py || die "sed in setup.py failed"
	# Workaround to make checks work without installing them.
	sed -i -e "s/pysqlite2.test/test/" \
		pysqlite2/test/__init__.py || die "sed failed"
	# Correct encoding.
	sed -i -e "s/\(coding: \)ISO-8859-1/\1utf-8/" \
		pysqlite2/__init__.py pysqlite2/dbapi2.py || die "sed failed"

	# setup.cfg has hardcoded non-prefix paths, kill them
	cd "${S}"
	sed -i \
		-e '/^include_dirs=/d' \
		-e '/^library_dirs=/d' \
		setup.cfg
}

src_install() {
	distutils_src_install

	rm -rf "${ED}"/usr/pysqlite2-doc

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r doc/includes/sqlite3
	fi
}

src_test() {
	cd pysqlite2
	# Tests use this as a nonexistent file.
	addpredict /foo/bar
	testing() {
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" -c \
			"from test import test;import sys;sys.exit(test())"
	}
	python_execute_function testing
}
