# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-0.96.ebuild,v 1.5 2007/09/27 23:52:02 ranger Exp $

EAPI="prefix"

inherit bash-completion distutils eutils versionator

RPV=$(get_version_component_range 1-2)

MY_P="Django-${PV}"

DESCRIPTION="high-level python web framework"
HOMEPAGE="http://www.djangoproject.com/"
SRC_URI="http://media.djangoproject.com/releases/${RPV}/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="examples mysql postgres sqlite test"

RDEPEND="dev-python/imaging
	sqlite? ( || (
		( >=dev-python/pysqlite-2.0.3 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	test? ( || (
		( >=dev-python/pysqlite-2.0.3 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5 ) )
	postgres? ( dev-python/psycopg )
	mysql? ( >=dev-python/mysql-python-1.2.1_p2 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS="docs/* AUTHORS"

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
