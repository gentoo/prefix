# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/php/php-5.3.8.ebuild,v 1.9 2011/09/22 17:35:18 olemarkus Exp $

EAPI=4

PHPCONFUTILS_MISSING_DEPS="adabas birdstep db2 dbmaker empress empress-bcs esoob interbase oci8 sapdb solid"

inherit eutils autotools flag-o-matic versionator depend.apache apache-module db-use phpconfutils php-common-r1 libtool prefix

SUHOSIN_VERSION="5.3.7-0.9.10"
FPM_VERSION="builtin"
EXPECTED_TEST_FAILURES=""

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"

function php_get_uri ()
{
	case "${1}" in
		"php-pre")
			echo "http://downloads.php.net/ilia/${2}"
		;;
		"php")
			echo "http://www.php.net/distributions/${2}"
		;;
		"suhosin")
			echo "http://download.suhosin.org/${2}"
		;;
		"olemarkus")
			echo "http://olemarkus.org/~olemarkus/gentoo/${2}"
		;;
		"gentoo")
			echo "mirror://gentoo/${2}"
		;;
		*)
			die "unhandled case in php_get_uri"
		;;
	esac
}

PHP_MV="$(get_major_version)"

# alias, so we can handle different types of releases (finals, rcs, alphas,
# betas, ...) w/o changing the whole ebuild
PHP_PV="${PV/_rc/RC}"
PHP_RELEASE="php"
PHP_P="${PN}-${PHP_PV}"

PHP_PATCHSET_LOC="olemarkus"

PHP_SRC_URI="$(php_get_uri "${PHP_RELEASE}" "${PHP_P}.tar.bz2")"

PHP_PATCHSET="0"
PHP_PATCHSET_URI="
	$(php_get_uri "${PHP_PATCHSET_LOC}" "php-patchset-${PV}-r${PHP_PATCHSET}.tar.bz2")"

PHP_FPM_INIT_VER="4"
PHP_FPM_CONF_VER="1"

if [[ ${SUHOSIN_VERSION} == *-gentoo ]]; then
	# in some cases we use our own suhosin patch (very recent version,
	# patch conflicts, etc.)
	SUHOSIN_TYPE="gentoo"
else
	SUHOSIN_TYPE="suhosin"
fi

if [[ -n ${SUHOSIN_VERSION} ]]; then
	SUHOSIN_PATCH="suhosin-patch-${SUHOSIN_VERSION}.patch";
	SUHOSIN_URI="$(php_get_uri ${SUHOSIN_TYPE} ${SUHOSIN_PATCH}.gz )"
fi

SRC_URI="
	${PHP_SRC_URI}
	${PHP_PATCHSET_URI}"

if [[ -n ${SUHOSIN_VERSION} ]]; then
	SRC_URI="${SRC_URI}
		suhosin? ( ${SUHOSIN_URI} )"
fi

DESCRIPTION="The PHP language runtime engine: CLI, CGI, FPM/FastCGI, Apache2 and embed SAPIs."
HOMEPAGE="http://php.net/"
LICENSE="PHP-3"

SLOT="$(get_version_component_range 1-2)"
S="${WORKDIR}/${PHP_P}"

# We can build the following SAPIs in the given order
SAPIS="embed cli cgi fpm apache2"

# Gentoo-specific, common features
IUSE="kolab"

# SAPIs and SAPI-specific USE flags (cli SAPI is default on):
IUSE="${IUSE}
	${SAPIS/cli/+cli}
	threads"

IUSE="${IUSE} adabas bcmath berkdb birdstep bzip2 calendar cdb cjk
	crypt +ctype curl curlwrappers db2 dbmaker debug doc empress
	empress-bcs enchant esoob exif frontbase +fileinfo +filter firebird
	flatfile ftp gd gd-external gdbm gmp +hash +iconv imap inifile
	interbase intl iodbc ipv6 +json kerberos ldap ldap-sasl libedit mhash
	mssql mysql mysqlnd mysqli nls oci8
	oci8-instant-client odbc pcntl pdo +phar pic +posix postgres qdbm
	readline recode sapdb +session sharedext sharedmem
	+simplexml snmp soap sockets solid spell sqlite sqlite3 ssl
	sybase-ct sysvipc tidy +tokenizer truetype unicode wddx
	+xml xmlreader xmlwriter xmlrpc xpm xsl zip zlib"

# Enable suhosin if available
[[ -n $SUHOSIN_VERSION ]] && IUSE="${IUSE} suhosin"

DEPEND="!dev-lang/php:5
	>=app-admin/eselect-php-0.6.2
	>=dev-libs/libpcre-8.12[unicode]
	adabas? ( >=dev-db/unixODBC-1.8.13 )
	apache2? ( www-servers/apache[threads=] )
	berkdb? ( =sys-libs/db-4* )
	birdstep? ( >=dev-db/unixODBC-1.8.13 )
	bzip2? ( app-arch/bzip2 )
	cdb? ( || ( dev-db/cdb dev-db/tinycdb ) )
	cjk? ( !gd? ( !gd-external? (
		virtual/jpeg
		media-libs/libpng
		sys-libs/zlib
	) ) )
	crypt? ( >=dev-libs/libmcrypt-2.4 )
	curl? ( >=net-misc/curl-7.10.5 )
	db2? ( >=dev-db/unixODBC-1.8.13 )
	dbmaker? ( >=dev-db/unixODBC-1.8.13 )
	empress? ( >=dev-db/unixODBC-1.8.13 )
	empress-bcs? ( >=dev-db/unixODBC-1.8.13 )
	enchant? ( app-text/enchant )
	esoob? ( >=dev-db/unixODBC-1.8.13 )
	exif? ( !gd? ( !gd-external? (
		virtual/jpeg
		media-libs/libpng
		sys-libs/zlib
	) ) )
	firebird? ( dev-db/firebird )
	gd? ( virtual/jpeg media-libs/libpng sys-libs/zlib )
	gd-external? ( media-libs/gd )
	gdbm? ( >=sys-libs/gdbm-1.8.0 )
	gmp? ( >=dev-libs/gmp-4.1.2 )
	iconv? ( virtual/libiconv )
	imap? ( virtual/imap-c-client[ssl=] )
	intl? ( dev-libs/icu )
	iodbc? ( dev-db/libiodbc )
	kerberos? ( virtual/krb5 )
	kolab? ( >=net-libs/c-client-2004g-r1 )
	ldap? ( !oci8? ( >=net-nds/openldap-1.2.11 ) )
	ldap-sasl? ( !oci8? ( dev-libs/cyrus-sasl >=net-nds/openldap-1.2.11 ) )
	libedit? ( || ( sys-freebsd/freebsd-lib dev-libs/libedit ) )
	mssql? ( dev-db/freetds[mssql] )
	!mysqlnd? (
		mysql? ( virtual/mysql )
		mysqli? ( >=virtual/mysql-4.1 )
	)
	nls? ( sys-devel/gettext )
	oci8-instant-client? ( dev-db/oracle-instantclient-basic )
	odbc? ( >=dev-db/unixODBC-1.8.13 )
	postgres? ( dev-db/postgresql-base )
	qdbm? ( dev-db/qdbm )
	readline? ( sys-libs/readline )
	recode? ( app-text/recode )
	sapdb? ( >=dev-db/unixODBC-1.8.13 )
	sharedmem? ( dev-libs/mm )
	simplexml? ( >=dev-libs/libxml2-2.6.8 )
	snmp? ( >=net-analyzer/net-snmp-5.2 )
	soap? ( >=dev-libs/libxml2-2.6.8 )
	solid? ( >=dev-db/unixODBC-1.8.13 )
	spell? ( >=app-text/aspell-0.50 )
	sqlite? ( =dev-db/sqlite-2* pdo? ( >=dev-db/sqlite-3.7.7.1 ) )
	sqlite3? ( >=dev-db/sqlite-3.7.7.1 )
	ssl? ( >=dev-libs/openssl-0.9.7 )
	sybase-ct? ( dev-db/freetds )
	tidy? ( app-text/htmltidy )
	truetype? (
		=media-libs/freetype-2*
		>=media-libs/t1lib-5.0.0
		!gd? ( !gd-external? (
			virtual/jpeg media-libs/libpng sys-libs/zlib ) )
	)
	unicode? ( dev-libs/oniguruma )
	wddx? ( >=dev-libs/libxml2-2.6.8 )
	xml? ( >=dev-libs/libxml2-2.6.8 )
	xmlrpc? ( >=dev-libs/libxml2-2.6.8 virtual/libiconv )
	xmlreader? ( >=dev-libs/libxml2-2.6.8 )
	xmlwriter? ( >=dev-libs/libxml2-2.6.8 )
	xpm? (
		x11-libs/libXpm
		virtual/jpeg
		media-libs/libpng sys-libs/zlib
	)
	xsl? ( dev-libs/libxslt >=dev-libs/libxml2-2.6.8 )
	zip? ( sys-libs/zlib )
	zlib? ( sys-libs/zlib )
	virtual/mta
"

php="=${CATEGORY}/${PF}"

REQUIRED_USE="
	truetype? ( || ( gd gd-external ) )
	cjk? ( || ( gd gd-external ) )
	exif? ( || ( gd gd-external ) )

	xpm? ( gd )
	gd? ( zlib !gd-external )
	gd-external? ( !gd )
	simplexml? ( xml )
	soap? ( xml )
	wddx? ( xml )
	xmlrpc? ( || ( xml iconv ) )
	xmlreader? ( xml )
	xsl? ( xml )
	ldap-sasl? ( ldap !oci8 )
	adabas? ( odbc )
	birdstep? ( odbc )
	dbmaker? ( odbc )
	empress-bcs? ( empress )
	empress? ( odbc )
	esoob? ( odbc )
	db2? ( odbc )
	sapdb? ( odbc )
	solid? ( odbc )
	kolab? ( imap )
	mhash? ( hash )
	phar? ( hash )
	mysqlnd? ( || (
		mysql
		mysqli
		pdo
	) )

	oci8? ( !oci8-instant-client !ldap-sasl )
	oci8-instant-client? ( !oci8 )

	qdbm? ( !gdbm )
	readline? ( !libedit )
	recode? ( !imap !mysql !mysqli )
	firebird? ( !interbase )
	sharedmem? ( !threads )

	!cli? ( !cgi? ( !fpm? ( !apache2? ( !embed? ( cli ) ) ) ) )"

DEPEND="${DEPEND}
	enchant? ( !dev-php5/pecl-enchant )
	fileinfo? ( !<dev-php5/pecl-fileinfo-1.0.4-r2 )
	filter? ( !dev-php5/pecl-filter )
	json? ( !dev-php5/pecl-json )
	phar? ( !dev-php5/pecl-phar )
	zip? ( !dev-php5/pecl-zip )"

[[ -n $SUHOSIN_VERSION ]] && RDEPEND="${RDEPEND} suhosin? (
=${CATEGORY}/${PN}-${SLOT}*[unicode] )"

RDEPEND="${DEPEND}"

DEPEND="${DEPEND}
	sys-devel/flex
	>=sys-devel/m4-1.4.3
	>=sys-devel/libtool-1.5.18"

# They are in PDEPEND because we need PHP installed first!
PDEPEND="doc? ( app-doc/php-docs )"

# No longer depend on the extension. The suhosin USE flag only installs the
# patch
#[[ -n $SUHOSIN_VERSION ]] && PDEPEND="${PDEPEND} suhosin? ( dev-php${PHP_MV}/suhosin )"

# Allow users to install production version if they want to

case "${PHP_INI_VERSION}" in
	production|development)
		;;
	*)
		PHP_INI_VERSION="development"
		;;
esac

PHP_INI_UPSTREAM="php.ini-${PHP_INI_VERSION}"
PHP_INI_FILE="php.ini"

want_apache

# eblit-core
# Usage: <function> [version] [eval]
# Main eblit engine
eblit-core() {
	[[ -z $FILESDIR ]] && FILESDIR="$(dirname $EBUILD)/files"
	local e v func=$1 ver=$2 eval_=$3
	for v in ${ver:+-}${ver} -${PVR} -${PV} "" ; do
		e="${FILESDIR}/eblits/${func}${v}.eblit"
		if [[ -e ${e} ]] ; then
			. "${e}"
			[[ ${eval_} == 1 ]] && eval "${func}() { eblit-run ${func} ${ver} ; }"
			return 0
		fi
	done
	return 1
}

# eblit-include
# Usage: [--skip] <function> [version]
# Includes an "eblit" -- a chunk of common code among ebuilds in a given
# package so that its functions can be sourced and utilized within the
# ebuild.
eblit-include() {
	local skipable=false r=0
	[[ $1 == "--skip" ]] && skipable=true && shift
	[[ $1 == pkg_* ]] && skipable=true

	[[ -z $1 ]] && die "Usage: eblit-include <function> [version]"
	eblit-core $1 $2
	r="$?"
	${skipable} && return 0
	[[ "$r" -gt "0" ]] && die "Could not locate requested eblit '$1' in ${FILESDIR}/eblits/"
}

# eblit-run-maybe
# Usage: <function>
# Runs a function if it is defined in an eblit
eblit-run-maybe() {
	[[ $(type -t "$@") == "function" ]] && "$@"
}

# eblit-run
# Usage: <function> [version]
# Runs a function defined in an eblit
eblit-run() {
	eblit-include --skip common "${*:2}"
	eblit-include "$@"
	eblit-run-maybe eblit-$1-pre
	eblit-${PN}-$1
	eblit-run-maybe eblit-$1-post
}

# eblit-pkg
# Usage: <phase> [version]
# Includes the given functions AND evals them so they're included in the binpkgs
eblit-pkg() {
	[[ -z $1 ]] && die "Usage: eblit-pkg <phase> [version]"
	eblit-core $1 $2 1
}

eblit-pkg pkg_setup v2

src_prepare() {
	eblit-run src_prepare v3 ;

	if [[ ${CHOST} == *-darwin* ]] ; then
		# http://bugs.php.net/bug.php?id=48795, bug #343481
		sed -i -e '/BUILD_CGI="\\$(CC)/s/CC/CXX/' configure || die
	fi
}
src_configure() { eblit-run src_configure v2 ; }
src_compile() { eblit-run src_compile v1 ; }
src_install() { eblit-run src_install v2 ; }
src_test() { eblit-run src_test v1 ; }
pkg_postinst() { eblit-run pkg_postinst v2 ; }
