# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/www-apps/trac/trac-0.11_beta2.ebuild,v 1.1 2008/04/28 17:40:34 rbu Exp $

EAPI="prefix"

inherit distutils webapp

MY_PV=${PV/_beta/b}
MY_P=Trac-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Trac is a minimalistic web-based project management, wiki and bug/issue tracking system."
HOMEPAGE="http://trac.edgewall.com/"
LICENSE="trac"
SRC_URI="http://ftp.edgewall.com/pub/trac/${MY_P}.tar.gz"

IUSE="cgi fastcgi mysql postgres sqlite subversion"

KEYWORDS="~amd64-linux ~x86-linux"

# doing so because tools, python packages... overlap
SLOT="0"
WEBAPP_MANUAL_SLOT="yes"

DEPEND="
	${DEPEND}
	dev-python/setuptools
	"

RDEPEND="
	${RDEPEND}
	dev-python/genshi
	dev-python/pygments
	>=dev-python/docutils-0.3.9
	dev-python/pytz
	cgi? (
		virtual/httpd-cgi
	)
	fastcgi? (
		virtual/httpd-fastcgi
	)
	mysql? (
		>=dev-python/mysql-python-1.2.1
		>=virtual/mysql-4.1
	)
	postgres? (
		>=dev-python/psycopg-2
	)
	sqlite? (
		>=dev-db/sqlite-3.3.4
		|| (
			>=dev-lang/python-2.5
			>=dev-python/pysqlite-2.3.2
		)
	)
	subversion? (
		>=dev-util/subversion-1.4.2
	)
	!www-apps/trac-webadmin
	"

# The following function should be added to eutils.eclass (see bug #143572):

# Generate an standard error message for missing USE flags
# in existing packages, and die.
#
# Usage: built_with_use_die <category/package> <functionality> [<USE flag>]
#    ex: built_with_use_die dev-util/subversion python
#    or: built_with_use_die www-servers/apache LDAP ldap
#
# Typical usage:
#	if ! built_with_use dev-util/subversion python ; then
#        built_with_use_die dev-util/subversion python
#   fi
#
# Note: when <USE flag> is not specified, <functionality> is used for the USE flag name.
built_with_use_die() {
	local package=$1
	local func=$2
	local use_flag=$3

	[[ -z ${use_flag} ]] && use_flag=${func}

	eerror "Your ${package} package has been built without"
	eerror "${func} support, please enable the '${use_flag}' USE flag and"
	eerror "re-emerge ${package}."
	elog "You can enable this USE flag either globally in /etc/make.conf,"
	elog "or just for specific packages in /etc/portage/package.use."
	die "${package} missing ${func} support"
}

pkg_setup() {
	webapp_pkg_setup

	if ! use mysql && ! use postgres && ! use sqlite ; then
		eerror "You must select at least one database backend, by enabling"
		eerror "at least one of the 'mysql', 'postgres' or 'sqlite' USE flags."
		die "no database backend selected"
	fi

	# python has built-in sqlite support starting from 2.5
	if use sqlite && \
		has_version ">=dev-lang/python-2.5" && \
		! has_version ">=dev-python/pysqlite-2.3" && \
		! built_with_use dev-lang/python sqlite ; then
		eerror "To use the sqlite database backend, you must either:"
		eerror "- build dev-lang/python with sqlite support, using the 'sqlite'"
		eerror "  USE flag, or"
		eerror "- emerge dev-python/pysqlite"
		die "missing python sqlite support"
	fi

	if use subversion && \
		! built_with_use dev-util/subversion python ; then
		built_with_use_die dev-util/subversion python
	fi

	ebegin "Creating tracd group and user"
	enewgroup tracd
	enewuser tracd -1 -1 -1 tracd
	eend ${?}
}

src_install() {
	webapp_src_preinst
	distutils_src_install

	# project environments might go in here
	keepdir /var/lib/trac

	# documentation
	dodoc AUTHORS RELEASE THANKS UPGRADE
	cp -r contrib "${ED}"/usr/share/doc/${P}/

	# tracd init script
	newconfd "${FILESDIR}"/tracd.confd tracd
	newinitd "${FILESDIR}"/tracd.initd tracd

	# prepare webapp master copy

	# if needed, install cgi/fcgi scripts
	if use cgi ; then
		cp cgi-bin/trac.cgi "${ED}"/${MY_CGIBINDIR} || die
	fi
	if use fastcgi ; then
		cp cgi-bin/trac.fcgi "${ED}"/${MY_CGIBINDIR} || die
	fi

	# copy graphics, css & js
#	cp -r htdocs/* ${ED}/${MY_HTDOCSDIR}

	for lang in en; do
		webapp_postinst_txt ${lang} "${FILESDIR}"/postinst-${lang}.txt
		webapp_postupgrade_txt ${lang} "${FILESDIR}"/postupgrade-${lang}.txt
	done

	webapp_src_install
}
