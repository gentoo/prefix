# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php5-sapi-r2.eclass,v 1.41 2006/10/14 20:27:21 swegener Exp $
#
# eclass/php5-sapi-r2.eclass
#               Eclass for building different php5 SAPI instances
#
#               Based on robbat2's work on the php4 sapi eclass
#
# Author(s)		Stuart Herbert
#				<stuart@gentoo.org>
#
# ========================================================================

# a list of the USE flags which PHP supports, but which we don't have
# required packages in the tree

CONFUTILS_MISSING_DEPS="adabas birdstep db2 dbmaker empress empress-bcs esoob frontbase hyperwave-api informix ingres mnogosearch msession msql oci8 oracle7 ovrimos pfpro sapdb solid sybase sybase-ct"

inherit flag-o-matic eutils confutils libtool


# set MY_PHP_P in the ebuild

# we only set these variables if we're building a copy of php which can be
# installed as a package in its own right
#
# copies of php which are compiled into other packages (e.g. php support
# for the thttpd web server) don't need these variables

if [ "${PHP_PACKAGE}" = 1 ]; then
	HOMEPAGE="http://www.php.net/"
	LICENSE="PHP-3"
	SRC_URI="http://www.php.net/distributions/${MY_PHP_P}.tar.bz2"
	S="${WORKDIR}/${MY_PHP_P}"
fi

IUSE="adabas bcmath berkdb birdstep bzip2 calendar cdb pdf crypt
ctype curl curlwrappers db2 dba dbase dbm dbmaker dbx debug dio empress
empress-bcs esoob exif fam firebird frontbase fdftk flatfile filepro ftp gd gd-external gdbm gmp hardenedphp hyperwave-api imap inifile iconv informix ingres interbase iodbc jpeg kerberos ldap libedit mcve memlimit mhash mime ming mkconfig mnogosearch msession msql mssql mysql mysqli ncurses nls nis oci8 odbc oracle7 ovrimos pcntl pcre pfpro png postgres posix qdbm readline recode sapdb sasl session sharedext sharedmem simplexml snmp soap sockets solid spell spl sqlite ssl sybase sybase-ct sysvipc threads tidy tiff tokenizer truetype wddx xsl xml xmlrpc xpm zlib"

# these USE flags should have the correct dependencies
DEPEND="$DEPEND
	!<=dev-php/php-4.99.99
	berkdb? ( =sys-libs/db-4* )
	bzip2? ( app-arch/bzip2 )
	pdf? ( >=media-libs/clibpdf-2 )
	crypt? ( >=dev-libs/libmcrypt-2.4 )
	curl? ( >=net-misc/curl-7.10.5 )
	fam? ( virtual/fam )
	fdftk? ( app-text/fdftk )
	firebird? ( dev-db/firebird  )
	gd-external? ( media-libs/gd )
	gdbm? ( >=sys-libs/gdbm-1.8.0 )
	gmp? ( dev-libs/gmp )
	imap? ( virtual/imap-c-client )
	iodbc? ( dev-db/libiodbc )
	jpeg? ( >=media-libs/jpeg-6b )
	kerberos? ( virtual/krb5 )
	ldap? ( >=net-nds/openldap-1.2.11 )
	libedit? ( dev-libs/libedit )
	mcve? ( net-libs/libmonetra )
	mhash? ( app-crypt/mhash )
	mime? ( sys-apps/file )
	ming? ( media-libs/ming )
	mssql? ( dev-db/freetds )
	mysql? ( dev-db/mysql )
	ncurses? ( sys-libs/ncurses )
	nls? ( sys-devel/gettext )
	odbc? ( >=dev-db/unixODBC-1.8.13 )
	postgres? ( >=dev-db/postgresql-7.1 )
	png? ( media-libs/libpng )
	qdbm? ( dev-db/qdbm )
	readline? ( sys-libs/readline )
	recode? ( app-text/recode )
	sharedmem? ( dev-libs/mm )
	simplexml? ( dev-libs/libxml2 )
	snmp? ( >=net-analyzer/net-snmp-5.2 )
	soap? ( dev-libs/libxml2 )
	spell? ( app-text/aspell )
	sqlite? ( =dev-db/sqlite-2* )
	ssl? ( >=dev-libs/openssl-0.9.7 )
	sybase? ( dev-db/freetds )
	tidy? ( app-text/htmltidy )
	tiff? ( media-libs/tiff )
	truetype? ( =media-libs/freetype-2* >=media-libs/t1lib-5.0.0 )
	wddx? ( dev-libs/expat )
	xpm? ( || ( x11-libs/libXpm virtual/x11 ) )
	xsl? ( dev-libs/libxslt )
	zlib? ( sys-libs/zlib ) "

# this would be xml?, but PEAR requires XML support
# this can become a USE flag when Gentoo bug #2272 has been resolved
DEPEND="$DEPEND
		dev-libs/libxml2"

# ========================================================================

PHP_BUILDTARGETS="${PHP_BUILDTARGETS} build-modules"
PHP_INSTALLTARGETS="${PHP_INSTALLTARGETS} install"

# ========================================================================

PHP_INI_DIR="/etc/php/${PHPSAPI}-php5"
PHP_INI_FILE="php.ini"

# ========================================================================
# Hardened-PHP Support
# ========================================================================
#
# I've done it like this so that we can support different versions of
# the patch for different versions of PHP

case "$PV" in
	5.0.4) HARDENEDPHP_PATCH="hardening-patch-$PV-0.3.2.patch.gz" ;;
esac

[ -n "$HARDENEDPHP_PATCH" ] && SRC_URI="${SRC_URI} hardenedphp? ( http://www.hardened-php.net/$HARDENEDPHP_PATCH )"

# ========================================================================

EXPORT_FUNCTIONS pkg_setup src_compile src_install src_unpack pkg_postinst

# ========================================================================
# INTERNAL FUNCTIONS
# ========================================================================

php5-sapi-r2_check_awkward_uses() {

	# disabled hardenedphp after many reports of problems w/ apache
	# need to look into this at some point

	if useq hardenedphp ; then
		eerror
		eerror "hardenedphp is reported to break php for some users."
		eerror "We've disabled this feature for now until it has been"
		eerror "thoroughly investigated."
		eerror
		eerror "Please disable the hardenedphp USE flag"
		die "hardenedphp support disabled"
	fi

	# snmp support seems broken, haven't looked into a fix for it yet

	if useq snmp && [ "$PHP_PV" = "5.0.3" ] ; then
		eerror
		eerror "The snmp support in PHP 5 is currently broken."
		eerror "Please disable the snmp USE flag"
		eerror
		die "snmp support doesn't compile"
	fi

	# mysqli support is disabled; see bug #53886

	if useq mysqli ; then
		eerror
		eerror "We currently do not support the mysqli extension"
		eerror "Support will be added once MySQL 4.1 is no longer package-masked"
		eerror
		die "mysqli not supported yet"
	fi

	# recode not available in 5.0.0; upstream bug
	if useq recode && [ "$PHP_PV" == "5.0.0" ]; then
		eerror
		eerror "Support for the 'recode' extension is currently broken UPSTREAM"
		eerror "See http://bugs.php.net/bug.php?id=28700 for details"
		eerror
		die "recode broken, upstream bug"
	fi

	# Sanity check for Oracle
	if useq oci8 && [ -z "${ORACLE_HOME}" ]; then
		eerror
		eerror "You must have the ORACLE_HOME variable in your environment!"
		eerror
		die "Oracle configuration incorrect; user error"
	fi

	if useq oci8 || useq oracle7; then
		if has_version  'dev-db/oracle-instantclient-basic'; then
			ewarn "Please ensure you have a full install of the Oracle client."
			ewarn "dev-db/oracle-instantclient* is NOT sufficent."
		fi
	fi

	if useq dba ; then
		#                     extension     USE flag    shared support?
		enable_extension_with "cdb"			"cdb"		1
		enable_extension_with "db4"			"berkdb"	1
		enable_extension_with "dbm"			"dbm"		1
		enable_extension_with "flatfile"	"flatfile"	1
		enable_extension_with "gdbm"		"gdbm"		1
		enable_extension_with "inifile"		"inifile"	1
		enable_extension_with "qdbm"		"qdbm"		1
	fi

	if useq dbx ; then
		confutils_use_depend_any "dbx" "frontbase" "mssql" "odbc" "postgres" "sybase-ct" "oci8" "sqlite"
		enable_extension_enable		"dbx"	"dbx"		1
	fi

	enable_extension_with 	"jpeg-dir" 		"jpeg" 		0 "/usr"
	if useq gd-external ; then
		enable_extension_with	"freetype-dir"	"truetype"	0 "/usr"
		enable_extension_with	"t1lib"			"truetype"	0 "/usr"
		enable_extension_enable	"gd-native-ttf"	"truetype" 	0
		enable_extension_enable	"gd-jis-conf"	"nls" 		0
		enable_extension_enable	"gd-native-ttf"	"truetype" 	0
		enable_extension_with 	"gd" 			"gd-external" 1 "/usr"
	else
		enable_extension_with	"freetype-dir"	"truetype"	0 "/usr"
		enable_extension_with	"t1lib"			"truetype"	0 "/usr"
		enable_extension_enable	"gd-jis-conf"	"nls"		0
		enable_extension_enable	"gd-native-ttf"	"truetype"	0
		enable_extension_with 	"png-dir" 		"png" 		0 "/usr"
		enable_extension_with 	"tiff-dir" 		"tiff" 		0 "/usr"
		enable_extension_with 	"xpm-dir" 		"xpm" 		0 "/usr/X11R6"
		# enable gd last, so configure can pick up the previous settings
		enable_extension_with 	"gd" 			"gd" 		0
	fi

	confutils_use_depend_any "jpeg" "gd" "gd-external" "pdf"
	confutils_use_depend_any "png"  "gd" "gd-external"
	confutils_use_depend_any "tiff" "gd" "gd-external"
	confutils_use_depend_any "xpm"  "gd" "gd-external"
	confutils_use_depend_all "png"  "zlib"

	if useq imap ; then
		enable_extension_with 	"imap" 			"imap" 		1
		# this is a PITA to deal with
		if useq ssl ; then
			#if [ -n "`strings ${ROOT}/usr/$(get_libdir)/c-client.* 2>/dev/null | grep ssl_onceonlyinit`" ]; then
			if built_with_use virtual/imap-c-client ssl ; then
				# the IMAP-SSL arg doesn't parse 'shared,/usr/lib' right
				enable_extension_with 	"imap-ssl" 		"ssl" 		0
			else
				msg="IMAP+SSL requested, but your IMAP libraries are built without SSL!"
				eerror "${msg}"
				die "${msg}"
			fi
		fi
	fi

	if useq ldap ; then
		enable_extension_with 		"ldap" 			"ldap" 			1
		enable_extension_with 		"ldap-sasl" 	"sasl" 			0
	fi

	if useq odbc ; then
		enable_extension_with		"unixODBC"		"odbc"			1 "/usr"

		enable_extension_with		"adabas"		"adabas"		1
		enable_extension_with		"birdstep"		"birdstep"		1
		enable_extension_with		"dbmaker"		"dbmaker"		1
		enable_extension_with		"empress"		"empress"		1
		if useq empress ; then
			enable_extension_with	"empress-bcs"	"empress-bcs"	0
		fi
		enable_extension_with		"esoob"			"esoob"			1
		enable_extension_with		"ibm-db2"		"db2"			1
		enable_extension_with		"iodbc"			"iodbc"			1 "/usr"
		enable_extension_with		"sapdb"			"sapdb"			1
		enable_extension_with		"solid"			"solid"			1
	fi

	if useq mysql; then
		enable_extension_with		"mysql"			"mysql"			1 "/usr/lib/mysql"
		enable_extension_with		"mysql-sock"	"mysql"			0 "/var/run/mysqld/mysqld.sock"
	fi
	if useq mysqli; then
		enable_extension_with		"mysqli"		"mysqli"		1 "/usr/bin/mysql_config"
	fi

	# QDBM doesn't play nicely with GDBM _or_ DBM
	confutils_use_conflict "qdbm" "gdbm" "dbm"
	# both provide the same functionality
	confutils_use_conflict "readline" "libedit"
	# Recode is not liked.
	confutils_use_conflict "recode" "mysql" "imap" "nis" #"yaz"

	if ! useq session ; then
		enable_extension_disable	"session"		"session"		1
	else
		enable_extension_with		"mm"			"sharedmem"		0
		enable_extension_with		"msession"		"msession"		1
	fi

	if ! useq sqlite ; then
		enable_extension_without	"sqlite"	"sqlite"	0
	else
		enable_extension_enable		"sqlite-utf8"	"nls"	0
	fi

	# MCVE needs openSSL
	confutils_use_depend_all "mcve"		"ssl"
	# A variety of extensions need DBA
	confutils_use_depend_all "cdb"		"dba"
	confutils_use_depend_all "berkdb"	"dba"
	confutils_use_depend_all "flatfile"	"dba"
	confutils_use_depend_all "gdbm"		"dba"
	confutils_use_depend_all "inifile"	"dba"
	confutils_use_depend_all "qdbm"		"dba"

	# build EXIF support if we support a file format that uses it
	confutils_use_depend_any "exif" "jpeg" "tiff"

	# GD library support
	confutils_use_depend_any "truetype" "gd" "gd-external"

	# ldap support
	confutils_use_depend_all "sasl" "ldap"

	# mysql support
	# This shouldn't conflict actually
	#confutils_use_conflict "mysqli" "mysql"

	# odbc support
	confutils_use_depend_all "adabas"		"odbc"
	confutils_use_depend_all "birdstep"		"odbc"
	confutils_use_depend_all "dbmaker"		"odbc"
	confutils_use_depend_all "empress"		"odbc"
	confutils_use_depend_all "empress-bcs"	"odbc" "empress"
	confutils_use_depend_all "esoob"		"odbc"
	confutils_use_depend_all "db2"			"odbc"
	confutils_use_depend_all "sapdb"		"odbc"
	confutils_use_depend_all "solid"		"odbc"

	# session support
	confutils_use_depend_all "msession"	"session"

	confutils_warn_about_missing_deps
}

# ========================================================================
# EXPORTED FUNCTIONS
# ========================================================================

php5-sapi-r2_pkg_setup() {
	# let's do all the USE flag testing before we do anything else
	# this way saves a lot of time

	php5-sapi-r2_check_awkward_uses
}

php5-sapi-r2_src_unpack() {
	if [ "${PHP_PACKAGE}" == 1 ]; then
		unpack ${A}
	fi

	cd ${PHP_S}

	# Patch PHP to show Gentoo as the server platform
	sed -i "s/PHP_UNAME=\`uname -a\`/PHP_UNAME=\`uname -s -n -r -v\`/g" configure
	# Patch for PostgreSQL support
	sed -e 's|include/postgresql|include/postgresql include/postgresql/pgsql|g' -i configure

	# Patch for session persistence bug
	epatch ${FILESDIR}/php5_soap_persistence_session.diff

	# stop php from activating the apache config, as we will do that ourselves
	for i in configure sapi/apache/config.m4 sapi/apache2filter/config.m4 sapi/apache2handler/config.m4 ; do
		sed -i.orig -e 's,-i -a -n php5,-i -n php5,g' $i
	done

	# hardenedphp support

	use hardenedphp && [ -n "$HARDENEDPHP_PATCH" ] && epatch ${DISTDIR}/${HARDENEDPHP_PATCH}

	# iodbc support
	use iodbc && epatch ${FILESDIR}/with-iodbc.diff

	# fix configure scripts to recognize uClibc
	uclibctoolize

	# Just in case ;-)
	chmod 755 configure

	# [ "${ARCH}" == "sparc" ] && epatch ${FILESDIR}/php-5.0-stdint.diff
	# epatch ${FILESDIR}/${MY_PHP_P}-missing-arches.patch
}

php5-sapi-r2_src_compile() {
	cd ${PHP_S}
	confutils_init

	my_conf="${my_conf} --with-config-file-path=${PHP_INI_DIR}"
	if [ "$PHPSAPI" == "cli" ]; then
		my_conf="${my_conf} --with-pear=/usr/share/php"
	else
		my_conf="${my_conf} --disable-cli --without-pear"
	fi

	#							extension		USE flag		shared support?
	enable_extension_enable		"bcmath"		"bcmath"		1
	enable_extension_with		"bz2"			"bzip2"			1
	enable_extension_enable		"calendar"		"calendar"		1
	enable_extension_with		"cpdflib"		"pdf"		1 # depends on jpeg
	enable_extension_disable	"ctype"			"ctype"			0
	enable_extension_with		"curl"			"curl"			1
	enable_extension_with		"curlwrappers"	"curlwrappers"	1
	enable_extension_enable		"dbase"			"dbase"			1
	enable_extension_enable		"dio"			"dio"			1
	enable_extension_disable	"dom"			"xml"			0
	enable_extension_enable		"exif"			"exif"			1
	enable_extension_with		"fam"			"fam"			1
	enable_extension_with		"fbsql"			"frontbase"		1
	enable_extension_with		"fdftk"			"fdftk"			1 "/opt/fdftk-6.0"
	enable_extension_enable		"filepro"		"filepro"		1
	enable_extension_enable		"ftp"			"ftp"			1
	enable_extension_with		"gettext"		"nls"			1
	enable_extension_with		"gmp"			"gmp"			1
	enable_extension_with		"hwapi"			"hyperwave-api"	1
	enable_extension_with		"iconv"			"iconv"			1
	enable_extension_with		"informix"		"informix"		1
	enable_extension_with		"ingres"		"ingres"		1
	enable_extension_with		"interbase"		"firebird"		1
	# iodbc support added by Tim Haynes <gentoo@stirfried.vegetable.org.uk>
	enable_extension_with 		"iodbc" 		"iodbc" 		0 "/usr"
	# ircg extension not supported on Gentoo at this time
	enable_extension_with		"kerberos"		"kerberos"		0
	enable_extension_disable	"libxml"		"xml"			0
	enable_extension_enable		"mbstring"		"nls"			1
	enable_extension_with		"mcrypt"		"crypt"			1
	enable_extension_with		"mcve"			"mcve"			1
	enable_extension_enable		"memory-limit"	"memlimit"		0
	enable_extension_with		"mhash"			"mhash"			1
	enable_extension_with		"mime-magic"	"mime"			0 "/usr/share/misc/file/magic.mime"
	enable_extension_with		"ming"			"ming"			1
	enable_extension_with		"mnogosearch"	"mnogosearch"	1
	enable_extension_with		"msql"			"msql"			1
	enable_extension_with		"mssql"			"mssql"			1
	enable_extension_with		"ncurses"		"ncurses"		1
	enable_extension_with		"oci8"			"oci8"			1
	enable_extension_with		"oracle"		"oracle7"		1
	enable_extension_with		"openssl"		"ssl"			1
	enable_extension_with		"openssl-dir"	"ssl"			0 "/usr"
	enable_extension_with		"ovrimos"		"ovrimos"		1
	enable_extension_enable		"pcntl" 		"pcntl" 		1
	enable_extension_without	"pcre-regx"		"pcre"			1
	enable_extension_with		"pfpro"			"pfpro"			1
	enable_extension_with		"pgsql"			"postgres"		1
	enable_extension_disable	"posix"			"posix"			1
	enable_extension_with		"pspell"		"spell"			1
	enable_extension_with		"recode"		"recode"		1
	enable_extension_disable	"simplexml"		"simplexml"		1
	enable_extension_enable		"shmop"			"sharedmem"		0
	enable_extension_with		"snmp"			"snmp"			1
	enable_extension_enable		"soap"			"soap"			1
	enable_extension_enable		"sockets"		"sockets"		1
	enable_extension_disable	"spl"			"spl"			1
	enable_extension_with		"sybase"		"sybase"		1
	enable_extension_with		"sybase-ct"		"sybase-ct"		1
	enable_extension_enable		"sysvmsg"		"sysvipc"		1
	enable_extension_enable		"sysvsem"		"sysvipc"		1
	enable_extension_enable		"sysvshm"		"sysvipc"		1
	enable_extension_with		"tidy"			"tidy"			1
	enable_extension_disable	"tokenizer"		"tokenizer"		1
	enable_extension_enable		"wddx"			"wddx"			1
	enable_extension_with		"xsl"			"xsl"			1
	#enable_extension_disable	"xml"			"xml"			1 # PEAR needs --enable-xml
	enable_extension_with		"xmlrpc"		"xmlrpc"		1
	enable_extension_enable		"yp"			"nis"			1
	enable_extension_with		"zlib"			"zlib"			1
	enable_extension_enable		"debug"			"debug"			0

	php5-sapi-r2_check_awkward_uses

	# DBA support
	enable_extension_enable		"dba"		"dba" 1

	# readline support
	#
	# you can use readline or libedit, but you can't use both
	enable_extension_with		"readline"		"readline"		0
	enable_extension_with		"libedit"		"libedit"		1

	# fix ELF-related problems
	if has_pic ; then
		einfo "Enabling PIC support"
		my_conf="${my_conf} --with-pic"
	fi

	# Bug 98694
	addpredict /etc/krb5.conf

	# all done

	econf ${my_conf} || die "configure failed"
	emake || die "make failed"
}

php5-sapi-r2_src_install() {
	cd ${PHP_S}
	addpredict /usr/share/snmp/mibs/.index

	useq sharedext && PHP_INSTALLTARGETS="${PHP_INSTALLTARGETS} install-modules"
	make INSTALL_ROOT=${D} $PHP_INSTALLTARGETS || die "install failed"

	# get the extension dir
	PHPEXTDIR="`${D}/usr/bin/php-config --extension-dir`"

	# don't forget the php.ini file
	local phpinisrc=php.ini-dist
	einfo "Setting extension_dir in php.ini"
	sed -e "s|^extension_dir .*$|extension_dir = ${PHPEXTDIR}|g" -i ${phpinisrc}

	# A patch for PHP for security. PHP-CLI interface is exempt, as it cannot be
	# fed bad data from outside.
	if [ "${PHPSAPI}" != "cli" ]; then
		einfo "Securing fopen wrappers"
		sed -e 's|^allow_url_fopen .*|allow_url_fopen = Off|g' -i ${phpinisrc}
	fi

	einfo "Setting correct include_path"
	sed -e 's|^;include_path .*|include_path = ".:/usr/share/php"|' -i ${phpinisrc}

	if useq sharedext; then
		for x in `ls ${D}${PHPEXTDIR}/*.so | sort`; do
			echo "extension=`basename ${x}`" >> ${phpinisrc}
		done;
	fi

	dodir ${PHP_INI_DIR}
	insinto ${PHP_INI_DIR}
	newins ${phpinisrc} ${PHP_INI_FILE}

	# php-config install the following, so we don't have to
	#
	# if 'mkconfig' USE flag is set, we create the phpconfig
	# source tarball ... this makes it easy for us to bump the
	# phpconfig package whenever we bump php

	if useq mkconfig ; then
		CONFIG_NAME=phpconfig-$PV
		CONFIG_DESTDIR=${T}/${CONFIG_NAME}

		einfo "Building source tarball for ${CONFIG_NAME}"

		mkdir -p ${CONFIG_DESTDIR}/usr/bin
		cp ${D}/usr/bin/{phpextdist,phpize,php-config} ${CONFIG_DESTDIR}/usr/bin/

		mkdir -p ${CONFIG_DESTDIR}/usr/lib/php
		cp -r ${D}/usr/lib/php/build ${CONFIG_DESTDIR}/usr/lib/php

		mkdir -p ${CONFIG_DESTDIR}/usr/include
		cp -r ${D}/usr/include/php ${CONFIG_DESTDIR}/usr/include

		cd ${T}
		tar -cf - ${CONFIG_NAME} | bzip2 -9 > ${CONFIG_NAME}.tar.bz2
		cd -

		einfo "Done; tarball is ${T}/${CONFIG_NAME}.tar.bz2"
	fi

	# move all the PEAR stuff from /usr/lib/php to /usr/share/php

	rm -rf ${D}/usr/lib/php/build
	dodir /usr/share/php

	for x in ${D}/usr/lib/php/* ; do
		if [ "`basename $x`" != 'extensions' ]; then
			mv $x ${D}/usr/share/php
		fi
	done

	# only the cli SAPI is allowed to install PEAR

	if [ "$PHPSAPI" != "cli" ]; then
		rm -f ${D}/usr/bin/pear
		rm -f ${D}/usr/share/php
	fi

	rm -rf ${D}/usr/bin/{phpextdist,phpize,php-config}
	rm -rf ${D}/usr/include/php

	# we let each SAPI install the man page
	# this does mean that the packages are in conflict for now
}

php5-sapi-r2_pkg_postinst() {
	ewarn "If you have additional third party PHP extensions (such as"
	ewarn "dev-php/eaccelerator) you may need to recompile them now."

	if useq curl; then
		ewarn "Please be aware that CURL can allow the bypass of open_basedir restrictions."
	fi
}

