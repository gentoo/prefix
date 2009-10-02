# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sqlobject/sqlobject-0.11.2.ebuild,v 1.1 2009/10/01 03:43:05 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

MY_PN="SQLObject"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Object-Relational Manager, aka database wrapper"
HOMEPAGE="http://sqlobject.org/"
SRC_URI="http://pypi.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc firebird mysql postgres sqlite"

RDEPEND=">=dev-python/formencode-0.2.2
		firebird? ( >=dev-python/kinterbasdb-3.0.2 )
		mysql? ( >=dev-python/mysql-python-0.9.2-r1 )
		postgres? ( dev-python/psycopg )
		sqlite? ( || ( >=dev-lang/python-2.5[sqlite] dev-python/pysqlite ) )"
DEPEND="${RDEPEND}
		dev-python/setuptools"
RESTRICT_PYTHON_ABIS="3.*"

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
