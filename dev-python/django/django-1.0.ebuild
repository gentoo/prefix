# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-1.0.ebuild,v 1.5 2008/11/05 01:17:05 fmccor Exp $

EAPI=1
inherit bash-completion distutils versionator

DESCRIPTION="high-level python web framework"
HOMEPAGE="http://www.djangoproject.com/"
SRC_URI="http://media.djangoproject.com/releases/${PV}/Django-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc examples mysql postgres sqlite3 test"

RDEPEND="dev-python/imaging
	sqlite3? ( || (
		( dev-python/pysqlite:2 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	test? ( || (
		( dev-python/pysqlite:2 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	postgres? ( dev-python/psycopg )
	mysql? ( >=dev-python/mysql-python-1.2.1_p2 )
	doc? ( >=dev-python/sphinx-0.3 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/#d/D}"

DOCS="docs/* AUTHORS"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#Submitted upstream http://code.djangoproject.com/ticket/8865
	#by pythonhead, accepted in trunk
	epatch "${FILESDIR}/${P}"-fields.py.patch
}

src_compile() {
	distutils_src_compile
	if use doc ; then
		cd docs
		emake html || die "docs failed"
	fi
}

src_test() {
	cat >> tests/settings.py << __EOF__
DATABASE_ENGINE='sqlite3'
ROOT_URLCONF='tests/urls.py'
SITE_ID=1
__EOF__
	PYTHONPATH="." ${python} tests/runtests.py --settings=settings -v1 || die "tests failed"
}

src_install() {
	distutils_python_version

	site_pkgs="$(python_get_sitedir)"
	export PYTHONPATH="${PYTHONPATH}:${ED}/${site_pkgs}"
	dodir ${site_pkgs}

	distutils_src_install

	dobashcompletion extras/django_bash_completion

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
	if use doc ; then
		rm -Rf docs/_build/html/_sources
		dohtml txt -r docs/_build/html/*
	fi
}
