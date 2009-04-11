# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sqlalchemy/sqlalchemy-0.5.2.ebuild,v 1.2 2009/03/20 13:15:50 josejx Exp $

NEED_PYTHON=2.4

inherit distutils

MY_P=SQLAlchemy-${PV/_}

DESCRIPTION="Python SQL toolkit and Object Relational Mapper."
HOMEPAGE="http://www.sqlalchemy.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
IUSE="doc examples firebird mssql mysql postgres sqlite test"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

# note: if you use psycopg-1, then you need egenix-mx-base
RDEPEND="firebird? ( dev-python/kinterbasdb )
	mssql? ( dev-python/pymssql )
	mysql? ( dev-python/mysql-python )
	postgres? (
		|| (
			( >=dev-python/psycopg-2 )
			( <dev-python/psycopg-2 dev-python/egenix-mx-base )
		)
	)
	sqlite? (
		>=dev-db/sqlite-3.3.13
		|| ( dev-python/pysqlite >=dev-lang/python-2.5 )
	)"

DEPEND="dev-python/setuptools
	test? (
		>=dev-db/sqlite-3.3.13
		|| ( dev-python/pysqlite >=dev-lang/python-2.5 )
	)"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install

	use doc && dohtml doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	PYTHONPATH="./test/" "${python}" test/alltests.py || die "tests failed"
}
