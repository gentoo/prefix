# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php5_2-sapi.eclass,v 1.4 2007/04/24 20:06:20 chtekk Exp $

# ========================================================================
#
# php5_2-sapi.eclass
#		Eclass for building different php5.2 SAPI instances
#
#		USE THIS ECLASS FOR THE "CONCENTRATED" PACKAGES
#
#		Based on robbat2's work on the php4 sapi eclass
#
# Author:	Stuart Herbert
#			<stuart@gentoo.org>
#
# Author:	Luca Longinotti
#			<chtekk@gentoo.org>
#
# ========================================================================

PHPCONFUTILS_MISSING_DEPS="adabas birdstep db2 dbmaker empress empress-bcs esoob frontbase interbase msql oci8 sapdb solid sybase sybase-ct"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit flag-o-matic autotools toolchain-funcs libtool eutils phpconfutils php-common-r1

# set MY_PHP_P in the ebuild

# we only set these variables if we're building a copy of php which can be
# installed as a package in its own right
#
# copies of php which are compiled into other packages (e.g. php support
# for the thttpd web server) don't need these variables

if [[ "${PHP_PACKAGE}" == 1 ]] ; then
	HOMEPAGE="http://www.php.net/"
	LICENSE="PHP-3"
	SRC_URI="http://www.php.net/distributions/${MY_PHP_P}.tar.bz2"
	S="${WORKDIR}/${MY_PHP_P}"
fi

IUSE="adabas bcmath berkdb birdstep bzip2 calendar cdb cjk crypt ctype curl curlwrappers db2 dbase dbmaker debug doc empress empress-bcs esoob exif frontbase fdftk filter firebird flatfile ftp gd gd-external gdbm gmp hash iconv imap inifile interbase iodbc ipv6 java-external json kerberos ldap ldap-sasl libedit mcve mhash msql mssql mysql mysqli ncurses nls oci8 oci8-instant-client odbc pcntl pcre pdo pdo-external pic posix postgres qdbm readline reflection recode sapdb session sharedext sharedmem simplexml snmp soap sockets solid spell spl sqlite ssl suhosin sybase sybase-ct sysvipc tidy tokenizer truetype unicode wddx xml xmlreader xmlwriter xmlrpc xpm xsl yaz zip zip-external zlib"

# these USE flags should have the correct dependencies
DEPEND="adabas? ( >=dev-db/unixODBC-1.8.13 )
		berkdb? ( =sys-libs/db-4* )
		birdstep? ( >=dev-db/unixODBC-1.8.13 )
		bzip2? ( app-arch/bzip2 )
		cdb? ( dev-db/cdb )
		cjk? ( !gd? ( !gd-external? ( >=media-libs/jpeg-6b media-libs/libpng sys-libs/zlib ) ) )
		crypt? ( >=dev-libs/libmcrypt-2.4 )
		curl? ( >=net-misc/curl-7.10.5 )
		db2? ( >=dev-db/unixODBC-1.8.13 )
		dbmaker? ( >=dev-db/unixODBC-1.8.13 )
		empress? ( >=dev-db/unixODBC-1.8.13 )
		empress-bcs? ( >=dev-db/unixODBC-1.8.13 )
		esoob? ( >=dev-db/unixODBC-1.8.13 )
		exif? ( !gd? ( !gd-external? ( >=media-libs/jpeg-6b media-libs/libpng sys-libs/zlib ) ) )
		fdftk? ( app-text/fdftk )
		firebird? ( dev-db/firebird )
		gd? ( >=media-libs/jpeg-6b media-libs/libpng sys-libs/zlib )
		gd-external? ( media-libs/gd )
		gdbm? ( >=sys-libs/gdbm-1.8.0 )
		gmp? ( >=dev-libs/gmp-4.1.2 )
		iconv? ( virtual/libiconv )
		imap? ( virtual/imap-c-client )
		iodbc? ( dev-db/libiodbc >=dev-db/unixODBC-1.8.13 )
		kerberos? ( virtual/krb5 )
		ldap? ( >=net-nds/openldap-1.2.11 )
		ldap-sasl? ( dev-libs/cyrus-sasl >=net-nds/openldap-1.2.11 )
		libedit? ( || ( sys-freebsd/freebsd-lib dev-libs/libedit ) )
		mcve? ( >=dev-libs/openssl-0.9.7 )
		mhash? ( app-crypt/mhash )
		mssql? ( dev-db/freetds )
		mysql? ( virtual/mysql )
		mysqli? ( >=virtual/mysql-4.1 )
		ncurses? ( sys-libs/ncurses )
		nls? ( sys-devel/gettext )
		oci8-instant-client? ( dev-db/oracle-instantclient-basic )
		odbc? ( >=dev-db/unixODBC-1.8.13 )
		postgres? ( >=dev-db/libpq-7.1 )
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
		sqlite? ( =dev-db/sqlite-2* pdo? ( =dev-db/sqlite-3* ) )
		ssl? ( >=dev-libs/openssl-0.9.7 )
		sybase? ( dev-db/freetds )
		tidy? ( app-text/htmltidy )
		truetype? ( =media-libs/freetype-2* >=media-libs/t1lib-5.0.0 !gd? ( !gd-external? ( >=media-libs/jpeg-6b media-libs/libpng sys-libs/zlib ) ) )
		wddx? ( >=dev-libs/libxml2-2.6.8 )
		xml? ( >=dev-libs/libxml2-2.6.8 )
		xmlrpc? ( >=dev-libs/libxml2-2.6.8 virtual/libiconv )
		xmlreader? ( >=dev-libs/libxml2-2.6.8 )
		xmlwriter? ( >=dev-libs/libxml2-2.6.8 )
		xpm? ( x11-libs/libXpm >=media-libs/jpeg-6b media-libs/libpng sys-libs/zlib )
		xsl? ( dev-libs/libxslt >=dev-libs/libxml2-2.6.8 )
		zip? ( sys-libs/zlib )
		zlib? ( sys-libs/zlib )
		virtual/mta"

# libswf conflicts with ming and should not
# be installed with the new PHP ebuilds
DEPEND="${DEPEND}
		!media-libs/libswf"

# force use of the internal extensions,
# as they're better maintained upstream
DEPEND="${DEPEND}
		!dev-php5/pecl-filter
		!dev-php5/pecl-json"

# simplistic for now
RDEPEND="${DEPEND}"

# those are only needed at compile-time
DEPEND="${DEPEND}
		>=sys-devel/m4-1.4.3
		>=sys-devel/libtool-1.5.18"

# Additional features
#
# They are in PDEPEND because we need PHP installed first!
PDEPEND="doc? ( app-doc/php-docs )
		filter? ( !dev-php5/pecl-filter )
		java-external? ( dev-php5/php-java-bridge )
		json? ( !dev-php5/pecl-json )
		mcve? ( dev-php5/pecl-mcve )
		pdo? ( !dev-php5/pecl-pdo )
		pdo-external? ( dev-php5/pecl-pdo )
		suhosin? ( dev-php5/suhosin )
		yaz? ( dev-php5/pecl-yaz )
		zip? ( !dev-php5/pecl-zip )
		zip-external? ( dev-php5/pecl-zip )"

# ========================================================================
# php.ini Support
# ========================================================================

PHP_INI_FILE="php.ini"
PHP_INI_UPSTREAM="php.ini-dist"

# ========================================================================

# PHP patchsets support
SRC_URI="${SRC_URI} http://gentoo.longitekk.com/php-patchset-${MY_PHP_PV}-r${PHP_PATCHSET_REV}.tar.bz2"

# Suhosin patch support
[[ -n "${SUHOSIN_PATCH}" ]] && SRC_URI="${SRC_URI} suhosin? ( http://gentoo.longitekk.com/${SUHOSIN_PATCH} )"

# ========================================================================

EXPORT_FUNCTIONS pkg_setup src_compile src_install src_unpack pkg_postinst

# ========================================================================
# INTERNAL FUNCTIONS
# ========================================================================

php5_2-sapi_check_use_flags() {
	# Multiple USE dependencies
	phpconfutils_use_depend_any "truetype" "gd" "gd" "gd-external"
	phpconfutils_use_depend_any "cjk" "gd" "gd" "gd-external"
	phpconfutils_use_depend_any "exif" "gd" "gd" "gd-external"

	# Simple USE dependencies
	phpconfutils_use_depend_all "xpm"				"gd"
	phpconfutils_use_depend_all "gd"				"zlib"
	phpconfutils_use_depend_all "simplexml"			"xml"
	phpconfutils_use_depend_all "soap"				"xml"
	phpconfutils_use_depend_all "wddx"				"xml"
	phpconfutils_use_depend_all "xmlrpc"			"xml"
	phpconfutils_use_depend_all "xmlreader"			"xml"
	phpconfutils_use_depend_all "xmlwriter"			"xml"
	phpconfutils_use_depend_all "xsl"				"xml"
	phpconfutils_use_depend_all "filter"			"pcre"
	phpconfutils_use_depend_all "xmlrpc"			"iconv"
	phpconfutils_use_depend_all "java-external"		"session"
	phpconfutils_use_depend_all "ldap-sasl"			"ldap"
	phpconfutils_use_depend_all "mcve"				"ssl"
	phpconfutils_use_depend_all "suhosin"			"unicode"
	phpconfutils_use_depend_all "adabas"			"odbc"
	phpconfutils_use_depend_all "birdstep"			"odbc"
	phpconfutils_use_depend_all "dbmaker"			"odbc"
	phpconfutils_use_depend_all "empress-bcs"		"odbc" "empress"
	phpconfutils_use_depend_all "empress"			"odbc"
	phpconfutils_use_depend_all "esoob"				"odbc"
	phpconfutils_use_depend_all "db2"				"odbc"
	phpconfutils_use_depend_all "iodbc"				"odbc"
	phpconfutils_use_depend_all "sapdb"				"odbc"
	phpconfutils_use_depend_all "solid"				"odbc"

	# Direct USE conflicts
	phpconfutils_use_conflict "gd" "gd-external"
	phpconfutils_use_conflict "oci8" "oci8-instant-client"
	phpconfutils_use_conflict "pdo" "pdo-external"
	phpconfutils_use_conflict "zip" "zip-external"
	phpconfutils_use_conflict "qdbm" "gdbm"
	phpconfutils_use_conflict "readline" "libedit"
	phpconfutils_use_conflict "recode" "mysql" "imap" "yaz"
	phpconfutils_use_conflict "sharedmem" "threads"

	# IMAP support
	php_check_imap

	# Mail support
	php_check_mta

	# PostgreSQL support
	php_check_pgsql

	# Oracle support
	php_check_oracle_8

	phpconfutils_warn_about_external_deps

	export PHPCONFUTILS_AUTO_USE="${PHPCONFUTILS_AUTO_USE}"
}

php5_2-sapi_set_php_ini_dir() {
	PHP_INI_DIR="/etc/php/${PHPSAPI}-php5"
	PHP_EXT_INI_DIR="${PHP_INI_DIR}/ext"
	PHP_EXT_INI_DIR_ACTIVE="${PHP_INI_DIR}/ext-active"
}

php5_2-sapi_install_ini() {
	destdir=/usr/$(get_libdir)/php5

	# get the extension dir, if not already defined
	[[ -z "${PHPEXTDIR}" ]] && PHPEXTDIR="`"${ED}/${destdir}/bin/php-config" --extension-dir`"

	# work out where we are installing the ini file
	php5_2-sapi_set_php_ini_dir

	cp "${PHP_INI_UPSTREAM}" "${PHP_INI_UPSTREAM}-${PHPSAPI}"
	local phpinisrc="${PHP_INI_UPSTREAM}-${PHPSAPI}"

	# Set the extension dir
	einfo "Setting extension_dir in php.ini"
	sed -e "s|^extension_dir .*$|extension_dir = ${PHPEXTDIR}|g" -i ${phpinisrc}

	# A patch for PHP for security
	einfo "Securing fopen wrappers"
	sed -e 's|^allow_url_fopen .*|allow_url_fopen = Off|g' -i ${phpinisrc}

	# Set the include path to point to where we want to find PEAR packages
	einfo "Setting correct include_path"
	sed -e 's|^;include_path = ".:/php/includes".*|include_path = ".:/usr/share/php5:/usr/share/php"|' -i ${phpinisrc}

	# Add needed MySQL extensions charset configuration
	local phpmycnfcharset=""

	if [[ "${PHPSAPI}" == "cli" ]] ; then
		phpmycnfcharset="`php_get_mycnf_charset cli`"
		einfo "MySQL extensions charset for 'cli' SAPI is: ${phpmycnfcharset}"
	elif [[ "${PHPSAPI}" == "cgi" ]] ; then
		phpmycnfcharset="`php_get_mycnf_charset cgi-fcgi`"
		einfo "MySQL extensions charset for 'cgi' SAPI is: ${phpmycnfcharset}"
	elif [[ "${PHPSAPI}" == "apache" ]] ; then
		phpmycnfcharset="`php_get_mycnf_charset apache`"
		einfo "MySQL extensions charset for 'apache' SAPI is: ${phpmycnfcharset}"
	elif [[ "${PHPSAPI}" == "apache2" ]] ; then
		phpmycnfcharset="`php_get_mycnf_charset apache2handler`"
		einfo "MySQL extensions charset for 'apache2' SAPI is: ${phpmycnfcharset}"
	else
		einfo "No supported SAPI found for which to get the MySQL charset."
	fi

	if [[ -n "${phpmycnfcharset}" ]] && [[ "${phpmycnfcharset}" != "empty" ]] ; then
		einfo "Setting MySQL extensions charset to ${phpmycnfcharset}"
		echo "" >> ${phpinisrc}
		echo "; MySQL extensions default connection charset settings" >> ${phpinisrc}
		echo "mysql.connect_charset = ${phpmycnfcharset}" >> ${phpinisrc}
		echo "mysqli.connect_charset = ${phpmycnfcharset}" >> ${phpinisrc}
		echo "pdo_mysql.connect_charset = ${phpmycnfcharset}" >> ${phpinisrc}
	else
		echo "" >> ${phpinisrc}
		echo "; MySQL extensions default connection charset settings" >> ${phpinisrc}
		echo ";mysql.connect_charset = utf8" >> ${phpinisrc}
		echo ";mysqli.connect_charset = utf8" >> ${phpinisrc}
		echo ";pdo_mysql.connect_charset = utf8" >> ${phpinisrc}
	fi

	dodir ${PHP_INI_DIR}
	insinto ${PHP_INI_DIR}
	newins ${phpinisrc} ${PHP_INI_FILE}

	dodir ${PHP_EXT_INI_DIR}
	dodir ${PHP_EXT_INI_DIR_ACTIVE}

	# Install any extensions built as shared objects
	if use sharedext ; then
		for x in `ls "${ED}/${PHPEXTDIR}/"*.so | sort` ; do
			inifilename=${x/.so/.ini}
			inifilename=`basename ${inifilename}`
			echo "extension=`basename ${x}`" >> "${ED}/${PHP_EXT_INI_DIR}/${inifilename}"
			dosym "${PHP_EXT_INI_DIR}/${inifilename}" "${PHP_EXT_INI_DIR_ACTIVE}/${inifilename}"
		done
	fi
}

# ========================================================================
# EXPORTED FUNCTIONS
# ========================================================================

php5_2-sapi_pkg_setup() {
	# let's do all the USE flag testing before we do anything else
	# this way saves a lot of time
	php5_2-sapi_check_use_flags
}

php5_2-sapi_src_unpack() {
	cd "${S}"

	# Change PHP branding
	PHPPR=${PR/r/}
	sed -e "s|^EXTRA_VERSION=\"\"|EXTRA_VERSION=\"-pl${PHPPR}-gentoo\"|g" -i configure.in || die "Unable to change PHP branding to -pl${PHPPR}-gentoo"

	# multilib-strict support
	if [[ -n "${MULTILIB_PATCH}" ]] && [[ -f "${WORKDIR}/${MULTILIB_PATCH}" ]] ; then
		epatch "${WORKDIR}/${MULTILIB_PATCH}"
	else
		ewarn "There is no multilib-strict patch available for this PHP release yet!"
	fi

	# Apply general PHP5 patches
	if [[ -d "${WORKDIR}/${MY_PHP_PV}/php5" ]] ; then
		EPATCH_SOURCE="${WORKDIR}/${MY_PHP_PV}/php5" EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch
	fi

	# Apply version-specific PHP patches
	if [[ -d "${WORKDIR}/${MY_PHP_PV}/${MY_PHP_PV}" ]] ; then
		EPATCH_SOURCE="${WORKDIR}/${MY_PHP_PV}/${MY_PHP_PV}" EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch
	fi

	# Patch PHP to show Gentoo as the server platform
	sed -e "s/PHP_UNAME=\`uname -a | xargs\`/PHP_UNAME=\`uname -s -n -r -v | xargs\`/g" -i configure.in || die "Failed to fix server platform name"

	# Disable interactive make test
	sed -e 's/'`echo "\!getenv('NO_INTERACTION')"`'/false/g' -i run-tests.php

	# Stop PHP from activating the Apache config, as we will do that ourselves
	for i in configure sapi/apache/config.m4 sapi/apache2filter/config.m4 sapi/apache2handler/config.m4 ; do
		sed -i.orig -e 's,-i -a -n php5,-i -n php5,g' ${i}
		sed -i.orig -e 's,-i -A -n php5,-i -n php5,g' ${i}
	done

	# Patch PHP to support heimdal instead of mit-krb5
	if has_version "app-crypt/heimdal" ; then
		sed -e 's|gssapi_krb5|gssapi|g' -i acinclude.m4 || die "Failed to fix heimdal libname"
		sed -e 's|PHP_ADD_LIBRARY(k5crypto, 1, $1)||g' -i acinclude.m4 || die "Failed to fix heimdal crypt library reference"
	fi

	# Patch for PostgreSQL support
	if use postgres ; then
		sed -e 's|include/postgresql|include/postgresql include/postgresql/pgsql|g' -i ext/pgsql/config.m4 || die "Failed to fix PostgreSQL include paths"
	fi

	# Suhosin support
	if use suhosin ; then
		if [[ -n "${SUHOSIN_PATCH}" ]] && [[ -f "${DISTDIR}/${SUHOSIN_PATCH}" ]] ; then
			epatch "${DISTDIR}/${SUHOSIN_PATCH}"
		else
			ewarn "There is no Suhosin patch available for this PHP release yet!"
		fi
	fi

	# Fix configure scripts to correctly support Suhosin
	einfo "Running aclocal"
	aclocal --force || die "Unable to run aclocal successfully"
	einfo "Running libtoolize"
	libtoolize --copy --force || die "Unable to run libtoolize successfully"

	# Rebuild configure to make sure it's up to date
	einfo "Rebuilding configure script"
	autoreconf --force -W no-cross || die "Unable to regenerate configure script successfully"

	# Run elibtoolize
	elibtoolize

	# Just in case ;-)
	chmod 0755 configure || die "Failed to chmod configure to 0755"
}

php5_2-sapi_src_compile() {
	destdir=/usr/$(get_libdir)/php5

	php5_2-sapi_set_php_ini_dir

	cd "${S}"

	phpconfutils_init

	my_conf="${my_conf} --with-config-file-path=${PHP_INI_DIR} --with-config-file-scan-dir=${PHP_EXT_INI_DIR_ACTIVE} --without-pear"

	#								extension		USE flag		shared support?
	phpconfutils_extension_enable	"bcmath"		"bcmath"		1
	phpconfutils_extension_with		"bz2"			"bzip2"			1
	phpconfutils_extension_enable	"calendar"		"calendar"		1
	phpconfutils_extension_disable	"ctype"			"ctype"			0
	phpconfutils_extension_with		"curl"			"curl"			1
	phpconfutils_extension_with		"curlwrappers"	"curlwrappers"	0
	phpconfutils_extension_enable	"dbase"			"dbase"			1
	phpconfutils_extension_disable	"dom"			"xml"			0
	phpconfutils_extension_enable	"exif"			"exif"			1
	phpconfutils_extension_with		"fbsql"			"frontbase"		1
	phpconfutils_extension_with		"fdftk"			"fdftk"			1 "/opt/fdftk-6.0"
	phpconfutils_extension_disable	"filter"		"filter"		0
	phpconfutils_extension_enable	"ftp"			"ftp"			1
	phpconfutils_extension_with		"gettext"		"nls"			1
	phpconfutils_extension_with		"gmp"			"gmp"			1
	phpconfutils_extension_disable	"hash"			"hash"			0
	phpconfutils_extension_without	"iconv"			"iconv"			0
	phpconfutils_extension_disable	"ipv6"			"ipv6"			0
	phpconfutils_extension_disable	"json"			"json"			0
	phpconfutils_extension_with		"kerberos"		"kerberos"		0 "/usr"
	phpconfutils_extension_disable	"libxml"		"xml"			0
	phpconfutils_extension_enable	"mbstring"		"unicode"		1
	phpconfutils_extension_with		"mcrypt"		"crypt"			1
	phpconfutils_extension_with		"mhash"			"mhash"			1
	phpconfutils_extension_with		"msql"			"msql"			1
	phpconfutils_extension_with		"mssql"			"mssql"			1
	phpconfutils_extension_with		"ncurses"		"ncurses"		1
	phpconfutils_extension_with		"openssl"		"ssl"			0
	phpconfutils_extension_with		"openssl-dir"	"ssl"			0 "/usr"
	phpconfutils_extension_enable	"pcntl" 		"pcntl" 		1
	phpconfutils_extension_without	"pcre-regex"	"pcre"			0
	phpconfutils_extension_disable	"pdo"			"pdo"			0
	phpconfutils_extension_with		"pgsql"			"postgres"		1
	phpconfutils_extension_disable	"posix"			"posix"			0
	phpconfutils_extension_with		"pspell"		"spell"			1
	phpconfutils_extension_with		"recode"		"recode"		1
	phpconfutils_extension_disable	"reflection"	"reflection"	0
	phpconfutils_extension_disable	"simplexml"		"simplexml"		0
	phpconfutils_extension_enable	"shmop"			"sharedmem"		0
	phpconfutils_extension_with		"snmp"			"snmp"			1
	phpconfutils_extension_enable	"soap"			"soap"			1
	phpconfutils_extension_enable	"sockets"		"sockets"		1
	phpconfutils_extension_disable	"spl"			"spl"			0
	phpconfutils_extension_with		"sybase"		"sybase"		1
	phpconfutils_extension_with		"sybase-ct"		"sybase-ct"		1
	phpconfutils_extension_enable	"sysvmsg"		"sysvipc"		1
	phpconfutils_extension_enable	"sysvsem"		"sysvipc"		1
	phpconfutils_extension_enable	"sysvshm"		"sysvipc"		1
	phpconfutils_extension_with		"tidy"			"tidy"			1
	phpconfutils_extension_disable	"tokenizer"		"tokenizer"		0
	phpconfutils_extension_enable	"wddx"			"wddx"			1
	phpconfutils_extension_disable	"xml"			"xml"			0
	phpconfutils_extension_disable	"xmlreader"		"xmlreader"		0
	phpconfutils_extension_disable	"xmlwriter"		"xmlwriter"		0
	phpconfutils_extension_with		"xmlrpc"		"xmlrpc"		1
	phpconfutils_extension_with		"xsl"			"xsl"			1
	phpconfutils_extension_enable	"zip"			"zip"			1
	phpconfutils_extension_with		"zlib"			"zlib"			1
	phpconfutils_extension_enable	"debug"			"debug"			0

	# DBA support
	if use cdb || use berkdb || use flatfile || use gdbm || use inifile || use qdbm ; then
		my_conf="${my_conf} --enable-dba${shared}"
	fi

	# DBA drivers support
	phpconfutils_extension_with "cdb"		"cdb"		0
	phpconfutils_extension_with "db4"		"berkdb"	0
	phpconfutils_extension_with "flatfile"	"flatfile"	0
	phpconfutils_extension_with "gdbm"		"gdbm"		0
	phpconfutils_extension_with "inifile"	"inifile"	0
	phpconfutils_extension_with	"qdbm"		"qdbm"		0

	# Support for the GD graphics library
	if use gd-external || phpconfutils_usecheck gd-external ; then
		phpconfutils_extension_with		"freetype-dir"	"truetype"		0 "/usr"
		phpconfutils_extension_with		"t1lib"			"truetype"		0 "/usr"
		phpconfutils_extension_enable	"gd-jis-conv"	"cjk" 			0
		phpconfutils_extension_with 	"gd" 			"gd-external"	1 "/usr"
	else
		phpconfutils_extension_with		"freetype-dir"	"truetype"		0 "/usr"
		phpconfutils_extension_with		"t1lib"			"truetype"		0 "/usr"
		phpconfutils_extension_enable	"gd-jis-conv"	"cjk"			0
		phpconfutils_extension_with		"jpeg-dir"		"gd"			0 "/usr"
		phpconfutils_extension_with 	"png-dir" 		"gd" 			0 "/usr"
		phpconfutils_extension_with 	"xpm-dir" 		"xpm" 			0 "/usr/X11R6"
		# enable gd last, so configure can pick up the previous settings
		phpconfutils_extension_with 	"gd" 			"gd" 			0
	fi

	# IMAP support
	if use imap || phpconfutils_usecheck imap ; then
		phpconfutils_extension_with		"imap"			"imap"			1
		phpconfutils_extension_with		"imap-ssl"		"ssl"			0
	fi

	# Interbase support
	if use firebird || use interbase ; then
		my_conf="${my_conf} --with-interbase=/usr"
	fi

	# LDAP support
	if use ldap || phpconfutils_usecheck ldap ; then
		phpconfutils_extension_with		"ldap"			"ldap"			1
		phpconfutils_extension_with		"ldap-sasl"		"ldap-sasl"		0
	fi

	# MySQL support
	if use mysql ; then
		phpconfutils_extension_with		"mysql"			"mysql"			1 "/usr"
		phpconfutils_extension_with		"mysql-sock"	"mysql"			0 "/var/run/mysqld/mysqld.sock"
	fi

	# MySQLi support
	phpconfutils_extension_with			"mysqli"		"mysqli"		1 "/usr/bin/mysql_config"

	# ODBC support
	if use odbc || phpconfutils_usecheck odbc ; then
		phpconfutils_extension_with		"unixODBC"		"odbc"			1 "/usr"

		phpconfutils_extension_with		"adabas"		"adabas"		1
		phpconfutils_extension_with		"birdstep"		"birdstep"		1
		phpconfutils_extension_with		"dbmaker"		"dbmaker"		1
		phpconfutils_extension_with		"empress"		"empress"		1
		if use empress || phpconfutils_usecheck empress ; then
			phpconfutils_extension_with	"empress-bcs"	"empress-bcs"	0
		fi
		phpconfutils_extension_with		"esoob"			"esoob"			1
		phpconfutils_extension_with		"ibm-db2"		"db2"			1
		phpconfutils_extension_with		"iodbc"			"iodbc"			1 "/usr"
		phpconfutils_extension_with		"sapdb"			"sapdb"			1
		phpconfutils_extension_with		"solid"			"solid"			1
	fi

	# Oracle support
	if use oci8 ; then
		phpconfutils_extension_with		"oci8"			"oci8"			1
	fi
	if use oci8-instant-client ; then
		OCI8IC_PKG="`best_version dev-db/oracle-instantclient-basic`"
		OCI8IC_PKG="`printf ${OCI8IC_PKG} | sed -e 's|dev-db/oracle-instantclient-basic-||g' | sed -e 's|-r.*||g'`"
		phpconfutils_extension_with		"oci8"			"oci8-instant-client"	1	"instantclient,/usr/lib/oracle/${OCI8IC_PKG}/client/lib"
	fi

	# PDO support
	if use pdo || phpconfutils_usecheck pdo ; then
		phpconfutils_extension_with		"pdo-dblib"		"mssql"			1
		# The PDO-Firebird driver is broken and unmaintained upstream
		# phpconfutils_extension_with	"pdo-firebird"	"firebird"		1
		phpconfutils_extension_with		"pdo-mysql"		"mysql"			1 "/usr"
		if use oci8 ; then
			phpconfutils_extension_with	"pdo-oci"		"oci8"			1
		fi
		if use oci8-instant-client ; then
			OCI8IC_PKG="`best_version dev-db/oracle-instantclient-basic`"
			OCI8IC_PKG="`printf ${OCI8IC_PKG} | sed -e 's|dev-db/oracle-instantclient-basic-||g' | sed -e 's|-r.*||g'`"
			phpconfutils_extension_with	"pdo-oci"		"oci8-instant-client"	1	"instantclient,/usr,${OCI8IC_PKG}"
		fi
		phpconfutils_extension_with		"pdo-odbc"		"odbc"			1 "unixODBC,/usr"
		phpconfutils_extension_with		"pdo-pgsql"		"postgres"		1
		phpconfutils_extension_with		"pdo-sqlite"	"sqlite"		1 "/usr"
	fi

	# readline/libedit support
	# You can use readline or libedit, but you can't use both
	phpconfutils_extension_with			"readline"		"readline"		0
	phpconfutils_extension_with			"libedit"		"libedit"		0

	# Session support
	if ! use session && ! phpconfutils_usecheck session ; then
		phpconfutils_extension_disable	"session"		"session"		0
	else
		phpconfutils_extension_with		"mm"			"sharedmem"		0
	fi

	# SQLite support
	if ! use sqlite && ! phpconfutils_usecheck sqlite ; then
		phpconfutils_extension_without	"sqlite"		"sqlite"		0
	else
		phpconfutils_extension_with		"sqlite"		"sqlite"		0 "/usr"
		phpconfutils_extension_enable	"sqlite-utf8"	"unicode"		0
	fi

	# Fix ELF-related problems
	if use pic || phpconfutils_usecheck pic ; then
		einfo "Enabling PIC support"
		my_conf="${my_conf} --with-pic"
	fi

	# Catch CFLAGS problems
	php_check_cflags

	# multilib support
	if [[ $(get_libdir) != lib ]] ; then
		my_conf="--with-libdir=$(get_libdir) ${my_conf}"
	fi

	# Support user-passed configuration parameters
	[[ -z "${EXTRA_ECONF}" ]] && EXTRA_ECONF=""

	# Set the correct compiler for cross-compilation
	tc-export CC

	# We don't use econf, because we need to override all of its settings
	./configure --prefix=${destdir} --host=${CHOST} --mandir=${destdir}/man --infodir=${destdir}/info --sysconfdir=/etc --cache-file=./config.cache ${my_conf} ${EXTRA_ECONF} || die "configure failed"
	emake || die "make failed"
}

php5_2-sapi_src_install() {
	destdir=/usr/$(get_libdir)/php5

	cd "${S}"

	addpredict /usr/share/snmp/mibs/.index

	# Install PHP
	make INSTALL_ROOT="${D}" install-build install-headers install-programs || die "make install failed"

	# Install missing header files
	if use unicode || phpconfutils_usecheck unicode ; then
		dodir ${destdir}/include/php/ext/mbstring
		insinto ${destdir}/include/php/ext/mbstring
		for x in `ls "${S}/ext/mbstring/"*.h` ; do
			file=`basename ${x}`
			doins ext/mbstring/${file}
		done
		dodir ${destdir}/include/php/ext/mbstring/oniguruma
		insinto ${destdir}/include/php/ext/mbstring/oniguruma
		for x in `ls "${S}/ext/mbstring/oniguruma/"*.h` ; do
			file=`basename ${x}`
			doins ext/mbstring/oniguruma/${file}
		done
		dodir ${destdir}/include/php/ext/mbstring/libmbfl/mbfl
		insinto ${destdir}/include/php/ext/mbstring/libmbfl/mbfl
		for x in `ls "${S}/ext/mbstring/libmbfl/mbfl/"*.h` ; do
			file=`basename ${x}`
			doins ext/mbstring/libmbfl/mbfl/${file}
		done
	fi

	# Get the extension dir, if not already defined
	[[ -z "${PHPEXTDIR}" ]] && PHPEXTDIR="`"${ED}/${destdir}/bin/php-config" --extension-dir`"

	# And install the modules to it
	if use sharedext ; then
		for x in `ls "${S}/modules/"*.so | sort` ; do
			module=`basename ${x}`
			modulename=${module/.so/}
			insinto "${PHPEXTDIR}"
			einfo "Installing PHP ${modulename} extension"
			doins "modules/${module}"
		done
	fi

	# Generate the USE file for PHP
	phpconfutils_generate_usefile

	# Create the directory where we'll put php5-only php scripts
	keepdir /usr/share/php5
}

php5_2-sapi_pkg_postinst() {
	ewarn
	ewarn "If you have additional third party PHP extensions (such as"
	ewarn "dev-php5/phpdbg) you may need to recompile them now."
	ewarn "A new way of enabling/disabling PHP extensions was introduced"
	ewarn "with the newer PHP packages releases, so please reemerge any"
	ewarn "PHP extensions you have installed to automatically adapt to"
	ewarn "the new configuration layout."
	if use sharedext ; then
		ewarn "The core PHP extensions are now loaded through external"
		ewarn ".ini files, not anymore using a 'extension=name.so' line"
		ewarn "in the php.ini file. Portage will take care of this by"
		ewarn "creating new, updated config-files, please make sure to"
		ewarn "install those using etc-update or dispatch-conf."
	fi
	ewarn

	if use curl ; then
		ewarn "Please be aware that CURL can allow the bypass of open_basedir restrictions."
		ewarn "This can be a security risk!"
		ewarn
	fi

	ewarn "The 'pic' USE flag was added to newer releases of dev-lang/php."
	ewarn "With PIC enabled, your PHP installation may become slower, but"
	ewarn "PIC is required on Hardened-Gentoo platforms (where the USE flag"
	ewarn "is enabled automatically). You may also need this on other"
	ewarn "configurations where TEXTRELs are disabled, for example when using"
	ewarn "certain PaX options in the kernel."
	ewarn

	ewarn "With PHP 5.2, some extensions were removed from PHP because"
	ewarn "they were unmaintained or moved to PECL. Our ebuilds reflect"
	ewarn "this: the Filepro and HwAPI (Hyperwave-API) extensions were"
	ewarn "removed altogether and have no available substitute."
	ewarn "The Informix extension was also removed, as well as the optional"
	ewarn "memory-limit setting: memory-limit is now always enforced!"
	ewarn "The 'vm-goto' and 'vm-switch' USE flags were also removed,"
	ewarn "since the alternative VMs aren't really supported upstream"
	ewarn "and were found to behave badly with PHP 5.2. Once their"
	ewarn "state becomes clearer, we'll consider readding the USE flags."
	ewarn "The Ming extension was removed from our PHP 5.2 ebuild, because"
	ewarn "there were serious problems with compilation and the required"
	ewarn "Ming library. This functionality will be reintroduced later"
	ewarn "as an independant, external PHP extension."
	ewarn "The configure option --enable-gd-native-ttf (enabled by the"
	ewarn "'truetype' USE flag) was removed at upstreams request,"
	ewarn "as it's considered old and broken."
	ewarn "Hardened-PHP was also removed from the PHP 5.2 ebuilds in"
	ewarn "favour of its successor Suhosin, enable the 'suhosin' USE"
	ewarn "flag to install it."
	ewarn

	ewarn "The 'xml' and 'xml2' USE flags were unified in only the 'xml' USE"
	ewarn "flag. To get the features that were once controlled by the 'xml2'"
	ewarn "USE flag, turn the 'xml' USE flag on."
	ewarn
}
