# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/django/django-1.0.2-r1.ebuild,v 1.4 2009/05/18 14:58:48 arfrever Exp $

EAPI="2"

inherit bash-completion distutils multilib versionator webapp

MY_P="${P/#d/D}-final"
WEBAPP_MANUAL_SLOT="yes"

DESCRIPTION="High-level python web framework"
HOMEPAGE="http://www.djangoproject.com/"
SRC_URI="http://media.djangoproject.com/releases/${PV}/${MY_P}.tar.gz
	test? ( mirror://gentoo/${P}-tests.tar.bz2 )"
# ${P}-tests.tar.bz2 is generated from http://code.djangoproject.com/svn/django/tags/releases/${PV}/tests

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc examples mysql postgres sqlite test"

RDEPEND="dev-python/imaging
	sqlite? ( || (
		( dev-python/pysqlite:2 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5[sqlite] ) )
	test? ( || (
		( dev-python/pysqlite:2 <dev-lang/python-2.5 )
		>=dev-lang/python-2.5[sqlite] ) )
	postgres? ( dev-python/psycopg )
	mysql? ( >=dev-python/mysql-python-1.2.1_p2 )"
DEPEND="${RDEPEND}
	doc? ( >=dev-python/sphinx-0.3 )"

S="${WORKDIR}/${MY_P}"

DOCS="docs/* AUTHORS"

src_compile() {
	distutils_src_compile

	if use doc ; then
		pushd docs > /dev/null
		emake html || die "Generation of HTML documentation failed"
		popd > /dev/null
	fi
}

src_test() {
	einfo "Running tests."
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
		mv docs/_build/html/{_,.}sources
		dohtml txt -r docs/_build/html/*
	fi

	insinto "${MY_HTDOCSDIR#${EPREFIX}}"
	doins -r "${ED}/${site_pkgs}"/django/contrib/admin/media/*

	#webapp_postinst_txt en "${WORKDIR}"/postinstall-en.txt
	webapp_src_install
}

pkg_preinst() {
	:
}

pkg_postinst() {
	bash-completion_pkg_postinst
	distutils_pkg_postinst
	einfo "Now, Django has the best of both worlds with Gentoo,"
	einfo "ease of deployment for production and development."
	echo
	elog "A copy of the admin media is available to"
	elog "webapp-config for installation in a webroot,"
	elog "as well as the traditional location in python's"
	elog "site-packages dir for easy development"
	echo
	echo
	ewarn "If you build Django-1.0.2 without USE=\"vhosts\""
	ewarn "webapp-config will automatically install the"
	ewarn "admin media into the localhost webroot."
}
