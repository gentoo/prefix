# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sqlobject/sqlobject-0.9.2.ebuild,v 1.1 2007/11/04 23:41:47 lucass Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

MY_PN=SQLObject
MY_P=${MY_PN}-${PV}

DESCRIPTION="Object-relational mapper for Python"
HOMEPAGE="http://sqlobject.org/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE="postgres mysql sqlite firebird doc"

RDEPEND="postgres? ( dev-python/psycopg )
		mysql? ( >=dev-python/mysql-python-0.9.2-r1 )
		sqlite? ( || ( dev-python/pysqlite >=dev-lang/python-2.5 ) )
		firebird? ( >=dev-python/kinterbasdb-3.0.2 )
		>=dev-python/formencode-0.2.2"
DEPEND="${RDEPEND}
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install

	if use doc; then
		cd "${S}/docs"
		dodoc *.txt
		dohtml -r presentation-2004-11
		insinto /usr/share/doc/${PF}
		doins -r europython
	fi
}

#src_test() {
#	cd sqlobject/tests
#	sed -i \
#		-e "s/\('-transactions': 'mysql\)',/\1 sqlite',/" \
#		dbtest.py
#	rm test_sqlobject_admin.py
#	py.test | tee pytest.log
#	tail -n 1 pytest.log | grep -q "failed" && die "tests failed"
#}
