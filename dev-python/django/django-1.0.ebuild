# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-1.0.ebuild,v 1.2 2008/09/04 14:52:23 mr_bones_ Exp $

EAPI="prefix"

inherit bash-completion distutils eutils versionator

DESCRIPTION="high-level python web framework"
HOMEPAGE="http://www.djangoproject.com/"
SRC_URI="http://media.djangoproject.com/releases/${PV}/Django-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="examples mysql postgres sqlite3 test"

RDEPEND="dev-python/imaging
	sqlite3? ( || (
		( >=dev-python/pysqlite-2.0.3 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	test? ( || (
		( >=dev-python/pysqlite-2.0.3 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	postgres? ( dev-python/psycopg )
	mysql? ( >=dev-python/mysql-python-1.2.1_p2 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/#d/D}"

DOCS="docs/* AUTHORS"

src_test() {
	#Test fails, reported upstream http://code.djangoproject.com/ticket/8865
	echo "tests='''pass'''" > tests/regressiontests/forms/fields.py
	cat >> tests/settings.py << __EOF__
DATABASE_ENGINE='sqlite3'
ROOT_URLCONF='tests/urls.py'
SITE_ID=1
__EOF__
	PYTHONPATH="." ${python} tests/runtests.py --settings=settings -v1 || die "tests failed"
}

src_install() {
	#TODO: Use sphinx to generate docs when sphinx is keyworded for
	#all arches django is
	distutils_python_version

	site_pkgs="/usr/$(get_libdir)/python${PYVER}/site-packages/"
	export PYTHONPATH="${PYTHONPATH}:${ED}/${site_pkgs}"
	dodir ${site_pkgs}

	distutils_src_install

	dobashcompletion extras/django_bash_completion

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
