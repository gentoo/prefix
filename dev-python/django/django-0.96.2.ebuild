# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-0.96.2.ebuild,v 1.2 2008/08/19 09:25:27 hawking Exp $

inherit bash-completion distutils eutils versionator

RPV=$(get_version_component_range 1-2)
EXTRAS_VERSION="0.96.1"

MY_P="Django-${PV}"

DESCRIPTION="high-level python web framework"
HOMEPAGE="http://www.djangoproject.com/"
SRC_URI="http://media.djangoproject.com/releases/${RPV}/${MY_P}.tar.gz
		http://media.djangoproject.com/releases/${RPV}/Django-${EXTRAS_VERSION}.tar.gz"
		# We need ${EXTRAS_VERSION} in SRC_URI, because it's the last release that
		# contains extras, tests and examples, see also src_unpack
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
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

src_unpack() {

	distutils_src_unpack

	# Those directories are missing from 0.96.2, so we copy them over from
	# Django-${EXTRAS_VERSION}:
	cp -pPR "${WORKDIR}/Django-${EXTRAS_VERSION}/examples" "${S}/" || die
	cp -pPR "${WORKDIR}/Django-${EXTRAS_VERSION}/extras" "${S}/" || die
	cp -pPR "${WORKDIR}/Django-${EXTRAS_VERSION}/tests" "${S}/" || die
	cp -pPR "${WORKDIR}/Django-${EXTRAS_VERSION}/django/contrib/formtools/templates" \
		"${S}/django/contrib/formtools/" || die

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
