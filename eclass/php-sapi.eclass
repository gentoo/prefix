# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-sapi.eclass,v 1.91 2006/11/23 14:02:50 vivo Exp $
# Author: Robin H. Johnson <robbat2@gentoo.org>

inherit eutils flag-o-matic multilib libtool

DESCRIPTION="PHP generic SAPI ebuild"

EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_preinst

[ -z "${MY_PN}" ] && MY_PN=php
if [ -z "${MY_PV}" ]; then
	MY_PV=${PV/_rc/RC}
	# maybe do stuff for beta/alpha/pre here too?
fi

# our major ver number
PHPMAJORVER=${MY_PV//\.*}

[ -z "${MY_P}" ] && MY_P=${MY_PN}-${MY_PV}
[ -z "${MY_PF}" ] && MY_PF=${MY_P}-${PR}
[ -z "${HOMEPAGE}" ] && HOMEPAGE="http://www.php.net/"
[ -z "${LICENSE}" ]	&& LICENSE="PHP-3"
[ -z "${PROVIDE}" ]	&& PROVIDE="virtual/php"
# PHP.net does automatic mirroring from this URI
[ -z "${SRC_URI_BASE}" ] && SRC_URI_BASE="http://www.php.net/distributions"
if [ -z "${SRC_URI}" ]; then
	SRC_URI="${SRC_URI_BASE}/${MY_P}.tar.bz2"
fi
# A patch for PHP for security. PHP-CLI interface is exempt, as it cannot be
# fed bad data from outside.
if [ "${PHPSAPI}" != "cli" ]; then
	SRC_URI="${SRC_URI} mirror://gentoo/php-4.3.2-fopen-url-secure.patch"
fi

# Patch for bug 50991, 49420
# Make sure the correct include_path is used.
SRC_URI="${SRC_URI} mirror://gentoo/php-4.3.6-includepath.diff http://dev.gentoo.org/~robbat2/distfiles/php-4.3.6-includepath.diff"

[ "${PV//4.3.6}" != "${PV}" ] && SRC_URI="${SRC_URI} http://www.apache.org/~jorton/php-4.3.6-pcrealloc.patch"

# Where we work
S=${WORKDIR}/${MY_P}

IUSE="X crypt curl firebird flash freetds gd gd-external gdbm imap informix ipv6 java jpeg ldap mcal memlimit mysql nls oci8 odbc pam png postgres snmp spell ssl tiff truetype xml2 yaz fdftk doc gmp kerberos hardenedphp mssql debug"

# Hardened-PHP support
#
# I've done it like this, so that we can support different versions of
# the patch for different versions of PHP

case "$PV" in
	4.3.11) HARDENEDPHP_PATCH="hardening-patch-$PV-0.3.2.patch.gz" ;;
	4.4.0) HARDENEDPHP_PATCH="hardening-patch-$PV-0.3.2.patch.gz" ;;
esac

[ -n "$HARDENEDPHP_PATCH" ] && SRC_URI="${SRC_URI} hardenedphp? ( http://www.hardened-php.net/$HARDENEDPHP_PATCH )"

# berkdb stuff is complicated
# we need db-1.* for ndbm
# and then either of db3 or db4
IUSE="${IUSE} berkdb"
RDEPEND="${RDEPEND} berkdb? ( =sys-libs/db-1*
						|| ( >=sys-libs/db-4.0.14-r2
							>=sys-libs/db-3.2.9-r9
						)
					)"

# Everything is in this list is dynamically linked agaist or needed at runtime
# in some other way
#
# 2004/03/28 - stuart - added dependency on the php manual snapshot

RDEPEND="${RDEPEND}
	!dev-lang/php
	app-arch/bzip2
	X? ( || ( x11-libs/libXpm virtual/x11 ) )
	crypt? ( >=dev-libs/libmcrypt-2.4 >=app-crypt/mhash-0.8 )
	curl? ( >=net-misc/curl-7.10.2 )
	x86? ( firebird? ( >=dev-db/firebird-1.0 ) )
	freetds? ( >=dev-db/freetds-0.53 )
	gd-external? ( media-libs/gd >=media-libs/jpeg-6b
		>=media-libs/libpng-1.2.5 )
	gd? ( >=media-libs/jpeg-6b >=media-libs/libpng-1.2.5 )
	gdbm? ( >=sys-libs/gdbm-1.8.0 )
	!alpha? ( !amd64? ( java? ( =virtual/jdk-1.4* dev-java/java-config ) ) )
	jpeg? ( >=media-libs/jpeg-6b )
	ldap? ( >=net-nds/openldap-1.2.11 )
	mysql? ( virtual/mysql )
	nls? ( sys-devel/gettext )
	odbc? ( >=dev-db/unixODBC-1.8.13 )
	pam? ( >=sys-libs/pam-0.75 )
	png? ( >=media-libs/libpng-1.2.5 )
	postgres? ( >=dev-db/postgresql-7.1 )
	snmp? ( net-analyzer/net-snmp )
	spell? ( app-text/aspell )
	ssl? ( >=dev-libs/openssl-0.9.5 )
	tiff? ( >=media-libs/tiff-3.5.5 )
	xml2? ( dev-libs/libxml2 >=dev-libs/libxslt-1.0.30 )
	truetype? ( =media-libs/freetype-2* =media-libs/freetype-1*
		media-libs/t1lib )
	>=net-libs/libwww-5.3.2
	>=app-text/sablotron-0.97
	dev-libs/expat
	sys-libs/zlib
	virtual/mta
	>=sys-apps/file-4.02
	yaz? ( dev-libs/yaz )
	doc? ( app-doc/php-docs )
	gmp? ( dev-libs/gmp )
	mssql? ( dev-db/freetds )
	kerberos? ( virtual/krb5 )"

# USE structure doesn't support ~x86
#if hasq '~x86' $ACCEPT_KEYWORDS; then
	# FDFTK only available for x86 type hardware
	#RDEPEND="${RDEPEND} x86? ( fdftk? ( app-text/fdftk ) )"
#fi

# libswf is ONLY available on x86
RDEPEND="${RDEPEND} flash? (
		x86? ( media-libs/libswf )
		>=media-libs/ming-0.2a )"

#The new XML extension in PHP5 requires libxml2-2.5.10
if [ "${PHPMAJORVER}" -ge 5 ]; then
	RDEPEND="${RDEPEND} >=dev-libs/libxml2-2.5.10"
fi

# ncurses and readline are only valid on the CLI php
if [ "${PN}" = "php" ]; then
	RDEPEND="${RDEPEND}
		readline? ( >=sys-libs/ncurses-5.1 >=sys-libs/readline-4.1 )
		ncurses? ( >=sys-libs/ncurses-5.1 )"
	IUSE="${IUSE} ncurses readline"
fi


# These are extra bits we need only at compile time
DEPEND="${RDEPEND} ${DEPEND}
	imap? ( virtual/imap-c-client )
	mcal? ( dev-libs/libmcal !=dev-libs/libmcal-0.7-r2 )"
#9libs causes a configure error
DEPEND="${DEPEND} !dev-libs/9libs"
#dev-libs/libiconv causes a compile failure
DEPEND="${DEPEND} !dev-libs/libiconv"

#Waiting for somebody to want this:
#cyrus? ( net-mail/cyrus-imapd net-mail/cyrus-imap-admin dev-libs/cyrus-imap-dev )

# this is because dev-php/php provides all of the PEAR stuff and some other
# required odds and ends, and only as of this version number.
PHP_PROVIDER_PKG="dev-php/php"
PHP_PROVIDER_PKG_MINPVR="4.3.4-r2"
php-sapi_is_providerbuild() {
	if [ "${CATEGORY}/${PN}" == "${PHP_PROVIDER_PKG}" ]; then
		return 0
	else
		return 1
	fi
}
php-sapi_is_providerbuild || PDEPEND="${PDEPEND} >=${PHP_PROVIDER_PKG}-${PHP_PROVIDER_PKG_MINPVR}"

#export this here so we can use it
myconf="${myconf}"

# These are the standard targets that we want to for the install stage since we
# can't do the full 'make install' You may need to add your own items here for
# SAPIs etc.
PHP_INSTALLTARGETS="${PHP_INSTALLTARGETS} install-modules install-programs"
# provided by PHP Provider:
# install-pear install-build install-headers install-programs
# for use by other ebuilds:
# install-sapi install-modules install-programs
#
# all ebuilds should have install-programs, and then delete everything except
# php-config.${PN}

# These are quick fixups for older ebuilds that didn't have PHPSAPI defined.
[ -z "${PHPSAPI}" -a "${PN}" = "php" ] && PHPSAPI="cli"
if [ -z "${PHPSAPI}" -a "${PN}" = "mod_php" ]; then
	use apache2 && PHPSAPI="apache2" || PHPSAPI="apache1"
fi

# Now enforce existance of PHPSAPI
if [ -z "${PHPSAPI}" ]; then
	msg="The PHP eclass needs a PHPSAPI setting!"
	eerror "${msg}"
	die "${msg}"
fi

# build the destination and php.ini detail
PHPINIDIRECTORY="/etc/php/${PHPSAPI}-php${PHPMAJORVER}"
PHPINIFILENAME="php.ini"

php-sapi_check_java_config() {
	JDKHOME="`java-config --jdk-home`"
	NOJDKERROR="You need to use java-config to set your JVM to a JDK!"
	if [ -z "${JDKHOME}" ] || [ ! -d "${JDKHOME}" ]; then
		eerror "${NOJDKERROR}"
		die "${NOJDKERROR}"
	fi

	# stuart@gentoo.org - 2003/05/18
	# Kaffe JVM is not a drop-in replacement for the Sun JDK at this time

	if echo $JDKHOME | grep kaffe > /dev/null 2>&1 ; then
		eerror
		eerror "PHP will not build using the Kaffe Java Virtual Machine."
		eerror "Please change your JVM to either Blackdown or Sun's."
		eerror
		eerror "To build PHP without Java support, please re-run this emerge"
		eerror "and place the line:"
		eerror "  USE='-java'"
		eerror "in front of your emerge command; e.g."
		eerror "  USE='-java' emerge mod_php"
		eerror
		eerror "or edit your USE flags in /etc/make.conf"
		die
	fi

	JDKVER=$(java-config --java-version 2>&1 | awk '/^java version/ { print $3 }' | xargs )
	einfo "Active JDK version: ${JDKVER}"
	case ${JDKVER} in
		1.4.*) ;;
		1.5.*) ewarn "Java 1.5 is NOT supported at this time, and might not work." ;;
		*) eerror "A Java 1.4 JDK is required for Java support in PHP." ; die ;;
	esac
}

php-sapi_src_unpack() {
	php-sapi_warning_mssql_freetds
	# this is obsolete
	# use xml || \
	# ( ewarn "You have the xml USE flag turned off. Previously this"
	#   ewarn "disabled XML support in PHP. However PEAR has a hard"
	#   ewarn "dependancy on it, so they are now enabled." )

	if use fdftk; then
		has_version app-text/fdftk || \
		die "app-text/fdftk is required for FDF support! Portage isn't up to the DEPEND structure for it yet"
	fi

	unpack ${MY_P}.tar.bz2
	cd ${S}

	# Configure Patch for hard-wired uname -a
	sed "s/PHP_UNAME=\`uname -a\`/PHP_UNAME=\`uname -s -n -r -v\`/g" -i configure
	# ensure correct perms on configure
	chmod 755 configure

	uclibctoolize

	# no longer needed and breaks pear - Tal, 20031223

	# fix PEAR installer for our packaging
	# we keep a backup of it as we need it at the end of the install
	#cp pear/PEAR/Registry.php pear/PEAR/Registry.old
	#sed -e "s:\$pear_install_dir\.:\'${D}/usr/lib/php/\' . :g" -i pear/PEAR/Registry.php

	sed -e 's|include/postgresql|include/postgresql include/postgresql/pgsql|g' -i configure

	# Bug 47498
	[ "${PV//4.3.6}" != "${PV}" ] && EPATCH_OPTS="-d ${S} -p1" epatch ${DISTDIR}/php-4.3.6-pcrealloc.patch

	# Bug 46768
	use kerberos && sed -i "s:-lgssapi_krb5:-lgssapi:" configure

	use hardenedphp && [ -n "$HARDENEDPHP_PATCH" ] && epatch ${DISTDIR}/${HARDENEDPHP_PATCH}
}


php-sapi_src_compile() {
	# cache this
	libdir="$(get_libdir)"

	# sanity checks
	if [ ! -x "/usr/sbin/sendmail" ]; then
		msg="You need a virtual/mta that provides /usr/sbin/sendmail!"
		eerror "${msg}"
		die "${msg}"
	fi

	if [ ! -f "/proc/self/stat" ]; then
		msg="You need /proc mounted for configure to complete correctly!"
		eerror "${msg}"
		die "${msg}"
	fi

	use java && use !alpha && use !amd64 && php-sapi_check_java_config

	if use berkdb; then
		einfo "Enabling NBDM"
		myconf="${myconf} --with-ndbm=/usr"
		#Hack to use db4
		if has_version '=sys-libs/db-4*' && grep -q -- '--with-db4' configure; then
			einfo "Enabling DB4"
			myconf="${myconf} --with-db4=/usr"
		elif has_version '=sys-libs/db-3*' && grep -q -- '--with-db3' configure; then
			einfo "Enabling DB3"
			myconf="${myconf} --with-db3=/usr"
		else
			einfo "Enabling DB2"
			myconf="${myconf} --with-db2=/usr"
		fi
	else
		einfo "Skipping DB2, DB3, DB4, NDBM support"
		myconf="${myconf} --without-db3 --without-db4 --without-db2 --without-ndbm"
	fi

	myconf="${myconf} `use_with crypt mcrypt /usr` `use_with crypt mhash /usr`"
	use x86 && myconf="${myconf} `use_with firebird interbase /opt/interbase`"
	myconf="${myconf} `use_with flash ming /usr`"
	use x86 && myconf="${myconf} `use_with flash swf /usr`"
	myconf="${myconf} `use_with freetds sybase /usr`"
	myconf="${myconf} `use_with gdbm gdbm /usr`"
	use x86 && myconf="${myconf} `use_with fdftk fdftk /opt/fdftk-6.0`"
	use !alpha && myconf="${myconf} `use_with java java ${JAVA_HOME}`"
	myconf="${myconf} `use_with mcal mcal /usr`"
	# fix bug 55150, our mcal is PAM-enabled
	use mcal && use pam && ! use imap && LDFLAGS="${LDFLAGS} -lpam"
	[ -n "${INFORMIXDIR}" ] && myconf="${myconf} `use_with informix informix ${INFORMIXDIR}`"
	[ -n "${ORACLE_HOME}" ] && myconf="${myconf} `use_with oci8 oci8 ${ORACLE_HOME}`"
	myconf="${myconf} `use_with odbc unixODBC /usr`"
	myconf="${myconf} `use_with postgres pgsql /usr`"
	myconf="${myconf} `use_with snmp snmp /usr`"
	use snmp && myconf="${myconf} --enable-ucd-snmp-hack"
	use X && myconf="${myconf} --with-xpm-dir=/usr/X11R6" LDFLAGS="${LDFLAGS} -L/usr/X11R6/lib"
	myconf="${myconf} `use_with gmp`"
	myconf="${myconf} `use_with mssql mssql /usr`"

	myconf="${myconf} --without-crack --without-pdflib"

	# This chunk is intended for png/tiff/jpg, as there are several things that need them, indepentandly!
	REQUIREPNG=
	REQUIREJPG=
	REQUIRETIFF=
	if use gd-external; then
		myconf="${myconf} --with-gd=/usr"
		REQUIREPNG=1
		if has_version '>=media-libs/gd-2.0.17'; then
			einfo "Fixing PHP for gd function name changes"
			sed -i 's:gdFreeFontCache:gdFontCacheShutdown:' ${S}/ext/gd/gd.c
		fi
	elif use gd; then
		myconf="${myconf} --with-gd"
		REQUIREPNG=1 REQUIREJPG=1
	else
		myconf="${myconf} --without-gd"
	fi
	use gd-external || use gd && myconf="${myconf} `use_enable truetype gd-native-ttf`"

	use png && REQUIREPNG=1
	use jpeg && REQUIREJPG=1
	use tiff && REQUIRETIFF=1
	if [ -n "${REQUIREPNG}" ]; then
		myconf="${myconf} --with-png=/usr --with-png-dir=/usr"
	else
		myconf="${myconf} --without-png"
	fi
	if [ -n "${REQUIREJPG}" ]; then
		myconf="${myconf} --with-jpeg=/usr --with-jpeg-dir=/usr --enable-exif"
	else
		myconf="${myconf} --without-jpeg"
	fi
	if [ -n "${REQUIRETIFF}" ]; then
		myconf="${myconf} --with-tiff=/usr --with-tiff-dir=/usr"
		LDFLAGS="${LDFLAGS} -ltiff"
	else
		myconf="${myconf} --without-tiff"
	fi

	if use mysql; then
		# check for mysql4.1 and mysql4.1 support in this php
		if [ -n "`mysql_config | grep '4.1'`" ] && grep -q -- '--with-mysqli' configure; then
			myconf="${myconf} --with-mysqli=/usr"
		else
			myconf="${myconf} --with-mysql=/usr"
			myconf="${myconf} --with-mysql-sock=`mysql_config --socket`"
		fi
	else
		myconf="${myconf} --without-mysql"
	fi

	if use truetype; then
		myconf="${myconf} --with-freetype-dir=/usr"
		myconf="${myconf} --with-ttf=/usr"
		myconf="${myconf} --with-t1lib=/usr"
	else
		myconf="${myconf} --without-ttf --without-t1lib"
	fi

	myconf="${myconf} `use_with nls gettext`"
	myconf="${myconf} `use_with spell pspell /usr` `use_with ssl openssl /usr`"
	myconf="${myconf} `use_with imap imap /usr` `use_with ldap ldap /usr`"
	myconf="${myconf} `use_with xml2 dom /usr` `use_with xml2 dom-xslt /usr`"
	myconf="${myconf} `use_with xml2 dom-exslt /usr`"
	myconf="${myconf} `use_with kerberos` `use_with pam`"
	myconf="${myconf} `use_enable memlimit memory-limit`"
	myconf="${myconf} `use_enable ipv6`"
	myconf="${myconf} `use_with yaz` `use_enable debug`"
	if use curl; then
		myconf="${myconf} --with-curlwrappers --with-curl=/usr"
	else
		myconf="${myconf} --without-curl"
	fi

	#Waiting for somebody to want Cyrus support :-)
	#myconf="${myconf} `use_with cyrus`"

	# dbx AT LEAST one of mysql/odbc/postgres/oci8/mssql
	use mysql || use odbc || use postgres || use oci8 || use mssql \
		&& myconf="${myconf} --enable-dbx" \
		|| myconf="${myconf} --disable-dbx"

	use imap && use ssl && \
	if [ -n "`strings ${ROOT}/usr/${libdir}/c-client.a 2>/dev/null | grep ssl_onceonlyinit`" ]; then
		myconf="${myconf} --with-imap-ssl"
		einfo "Building IMAP with SSL support."
	else
		ewarn "USE=\"imap ssl\" specified but IMAP is built WITHOUT ssl support."
		ewarn "Skipping IMAP-SSL support."
	fi


	# These were previously optional, but are now included directly as PEAR needs them.
	# Zlib is needed for XML
	myconf="${myconf} --with-zlib=/usr --with-zlib-dir=/usr"
	LIBS="${LIBS} -lxmlparse -lxmltok"
	myconf="${myconf} --with-sablot=/usr"
	myconf="${myconf} --enable-xslt"
	myconf="${myconf} --with-xslt-sablot"
	myconf="${myconf} --with-xmlrpc"
	myconf="${myconf} --enable-wddx"
	myconf="${myconf} --with-xml"

	#Some extensions need mbstring statically built
	myconf="${myconf} --enable-mbstring=all --enable-mbregex"

	# Somebody might want safe mode, but it causes some problems, so I disable it by default
	#myconf="${myconf} --enable-safe-mode"

	# These are some things that we don't really need use flags for, we just
	# throw them in for functionality. Somebody could turn them off if their
	# heart so desired
	# DEPEND - app-arch/bzip2
	myconf="${myconf} --with-bz2=/usr"
	# DEPEND - nothing
	myconf="${myconf} --with-cdb"

	# No DEPENDancies
	myconf="${myconf} --enable-pcntl"
	myconf="${myconf} --enable-bcmath"
	myconf="${myconf} --enable-calendar"
	myconf="${myconf} --enable-dbase"
	myconf="${myconf} --enable-filepro"
	myconf="${myconf} --enable-ftp"
	myconf="${myconf} --with-mime-magic=/usr/share/misc/file/magic.mime"
	myconf="${myconf} --enable-sockets"
	myconf="${myconf} --enable-sysvsem --enable-sysvshm --enable-sysvmsg"
	myconf="${myconf} --with-iconv"
	myconf="${myconf} --enable-shmop"
	myconf="${myconf} --enable-dio"
	myconf="${myconf} --enable-yp"

	# recode is NOT used as it conflicts with IMAP
	# iconv is better anyway

	# there is absolutely no reason to build ncurses/readline support on
	# anything other than the CLI sapi
	if [ "${PN}" = "php" ]; then
		myconf="${myconf} `use_with readline readline /usr`"
		# Readline and Ncurses are CLI PHP only
		# readline needs ncurses
		use ncurses || use readline \
			&& myconf="${myconf} --with-ncurses=/usr" \
			|| myconf="${myconf} --without-ncurses"
	else
		# both of these are not needed
		myconf="${myconf} --without-ncurses --without-readline"
	fi

	# Now actual base PHP settings
	myconf="${myconf} \
		--enable-inline-optimization \
		--enable-track-vars \
		--enable-trans-sid \
		--enable-versioning"

	einfo "Using INI file: ${PHPINIDIRECTORY}/${PHPINIFILENAME}"
	myconf="${myconf} \
		--with-config-file-path=${PHPINIDIRECTORY}"

	myconf="${myconf} --libdir=/usr/${libdir}/php"

	# only provide pear is we are a provider build, and if we do, put it in
	# /usr/lib/php.
	if php-sapi_is_providerbuild; then
		myconf="${myconf} --with-pear=/usr/lib/php"
	else
		myconf="${myconf} --without-pear"
	fi


	# fix ELF-related problems
	if has_pic ; then
		myconf="${myconf} --with-pic"
	fi

	# filter the following from C[XX]FLAGS regardless, as apache won't be
	# supporting LFS until 2.2 is released and in the tree.  Fixes bug #24373.
	filter-flags "-D_FILE_OFFSET_BITS=64"
	filter-flags "-D_FILE_OFFSET_BITS=32"
	filter-flags "-D_LARGEFILE_SOURCE=1"
	filter-flags "-D_LARGEFILE_SOURCE"

	#fixes bug #14067
	# changed order to run it in reverse for bug #32022 and #12021
	replace-flags "-march=k6-3" "-march=i586"
	replace-flags "-march=k6-2" "-march=i586"
	replace-flags "-march=k6" "-march=i586"

	# Bug 98694
	addpredict /etc/krb5.conf

	if [ -z "${PHP_SKIP_CONFIGURE}" ]; then
		LDFLAGS="${LDFLAGS} -L/usr/${libdir}" LIBS="${LIBS}" econf \
		${myconf} || die "bad ./configure, please include ${MY_P}/config.log in any bug reports."
	fi

	if [ -z "${PHP_SKIP_MAKE}" ]; then
		emake || die "compile problem"
	fi
}

php-sapi_src_install() {
	# cache this
	libdir="$(get_libdir)"

	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/
	dodir /usr/bin
	dodir /usr/${libdir}/php
	dodir /usr/include/php

	# parallel make breaks it
	# so no emake here
	einfo "Running make INSTALL_ROOT=${D} ${PHP_INSTALLTARGETS}"
	make INSTALL_ROOT=${D} ${PHP_INSTALLTARGETS} || die

	# install a php-config for EACH instance of php
	# the PHP provider $PHP_PROVIDER_PKG one is the default
	mv ${D}/usr/bin/php-config ${D}/usr/bin/php-config.${PN}
	# these files are provided solely by the PHP provider ebuild
	if php-sapi_is_providerbuild ; then
		dosym /usr/bin/php-config.${PN} /usr/bin/php-config
	else
		rm -rf ${D}/usr/bin/{phpize,phpextdist,php} ${D}/usr/${libdir}/php/build
	fi

	# get the extension dir
	PHPEXTDIR="`${D}/usr/bin/php-config.${PN} --extension-dir`"

	for doc in LICENSE EXTENSIONS CREDITS INSTALL README.* TODO* NEWS; do
		[ -s "$doc" ] && dodoc $doc
	done

	#install scripts
	exeinto /usr/bin

	# Support for Java extension
	# 1. install php_java.jar file into ${EXT_DIR}
	# 2. edit the php.ini file ready for installation
	# - stuart@gentoo.org
	local phpinisrc=php.ini-dist
	einfo "Setting extension_dir in php.ini"
	sed -e "s|extension_dir .*$|extension_dir = ${PHPEXTDIR}|g" -i ${phpinisrc}

	if use java && use !alpha; then
		# we put these into /usr/lib so that they cannot conflict with
		# other versions of PHP (e.g. PHP 4 & PHP 5)
		insinto ${PHPEXTDIR}
		einfo "Installing JAR for PHP"
		doins ext/java/php_java.jar

		einfo "Installing Java test page"
		newins ext/java/except.php java-test.php

		JAVA_LIBRARY="`grep -- '-DJAVALIB' Makefile | sed -e 's,.\+-DJAVALIB=\"\([^"]*\)\".*$,\1,g;'| sort | uniq `"
		sed -e "s|;java.library .*$|java.library = ${JAVA_LIBRARY}|g" -i ${phpinisrc}
		sed -e "s|;java.class.path .*$|java.class.path = ${PHPEXTDIR}/php_java.jar|g" -i ${phpinisrc}
		sed -e "s|;java.library.path .*$|java.library.path = ${PHPEXTDIR}|g" -i ${phpinisrc}
		sed -e "s|;extension=php_java.dll.*$|extension = java.so|g" -i ${phpinisrc}
		dosym ${PHPEXTDIR}/java.so ${PHPEXTDIR}/libphp_java.so
	fi

	# A patch for PHP for security. PHP-CLI interface is exempt, as it cannot be
	# fed bad data from outside.
	if [ "${PHPSAPI}" != "cli" ]; then
		einfo "Securing fopen wrappers"
		patch ${phpinisrc} <${DISTDIR}/php-4.3.2-fopen-url-secure.patch
	fi

	# Patch for bug 50991, 49420
	# Make sure the correct include_path is used.
	einfo "Setting correct include_path"
	patch ${phpinisrc} <${DISTDIR}/php-4.3.6-includepath.diff

	# A lot of ini file funkiness
	insinto ${PHPINIDIRECTORY}
	newins ${phpinisrc} ${PHPINIFILENAME}

	# 2004/03/28 - stuart@gentoo.org
	#
	# This is where we install header files that PHP itself doesn't install,
	# but which PECL packages depend on
	if php-sapi_is_providerbuild; then
		for x in ext/gd/gdcache.h ext/gd/gdttf.h ext/gd/php_gd.h ext/gd/libgd/gd.h ext/gd/libgd/gd_io.h ext/gd/libgd/gdcache.h ext/gd/libgd/gdfontg.h ext/gd/libgd/gdfontl.h ext/gd/libgd/gdfontmb.h ext/gd/libgd/gdfonts.h ext/gd/libgd/gdfontt.h ext/gd/libgd/gdhelpers.h ext/gd/libgd/jisx0208.h ext/gd/libgd/wbmp.h ext/mbstring/libmbfl/mbfl/mbfilter.h ext/mbstring/libmbfl/mbfl/mbfl_defs.h ext/mbstring/libmbfl/mbfl/mbfl_consts.h ext/mbstring/libmbfl/mbfl/mbfl_allocators.h ext/mbstring/libmbfl/mbfl/mbfl_encoding.h ext/mbstring/libmbfl/mbfl/mbfl_language.h ext/mbstring/libmbfl/mbfl/mbfl_string.h ext/mbstring/libmbfl/mbfl/mbfl_convert.h ext/mbstring/libmbfl/mbfl/mbfl_ident.h ext/mbstring/libmbfl/mbfl/mbfl_memory_device.h; do
			my_headerdir="/usr/include/php/`dirname $x`"
			#echo "$my_headerdir"
			if [ ! -d "${D}$my_headerdir" ]; then
				mkdir -p ${D}$my_headerdir
			fi
			cp $x ${D}/usr/include/php/$x
		done
	else
		rm -rf ${D}/usr/include/php/
	fi

	if php-sapi_is_providerbuild; then
		insinto /usr/${libdir}/php
		doins ${S}/run-tests.php
		fperms 644 /usr/${libdir}/php/run-tests.php
		einfo "Fixing PEAR cache location"
		local oldloc="${T}/pear/cache"
		local old="s:${#oldloc}:\"${oldloc}\""
		local newloc="/tmp/pear/cache"
		local new="s:${#newloc}:\"${newloc}\""
		sed "s|${old}|${new}|" -i ${D}/etc/pear.conf
		keepdir /tmp/pear/cache
	else
		einfo "Removing duplicate PEAR conf file"
		rm -f ${D}/etc/pear.conf 2>/dev/null
	fi

	# clean up documentation
	php-sapi_is_providerbuild || rm -rf ${D}/usr/share/man/man1/php.1*
}

php-sapi_pkg_preinst() {
	# obsolete
	einfo "Checking if we need to preserve a really old /etc/php4/php.ini file"
	if [ -e /etc/php4/php.ini ] && [ ! -L /etc/php4/php.ini ]; then
		ewarn "Old setup /etc/php4/php.ini file detected, moving to new location (${PHPINIDIRECTORY}/${PHPINIFILENAME})"
		mkdir -p ${PHPINIDIRECTORY}
		mv -f /etc/php4/php.ini ${PHPINIDIRECTORY}/${PHPINIFILENAME}
	else
		einfo "/etc/php4/php.ini doesn't exist or is a symlink, nothing wrong here"
	fi
}

php-sapi_pkg_postinst() {
	einfo "The INI file for this build is ${PHPINIDIRECTORY}/php.ini"
	php-sapi_warning_mssql_freetds
	if has_version 'dev-php/php-core'; then
		ewarn "The dev-php/php-core package is now obsolete. You should unmerge"
		ewarn "it, and re-merge >=dev-php/php-4.3.4-r2 afterwards to ensure"
		ewarn "your PHP installation is consistant."
	fi
	if has_version "<${PV}"; then
		ewarn "The php, php-cgi, and mod_php ebuilds no longer supply the"
		ewarn "crack and pdflib extensions. If you need these, please use"
		ewarn "the corresponding PECL packages by emerging PECL-crack or"
		ewarn "PECL-pdflib, respectively."
	fi
	ewarn "If you have additional third party PHP extensions (such as"
	ewarn "dev-php/eaccelerator) you may need to recompile them now."
	if use curl; then
		ewarn "Please be aware that CURL can allow the bypass of open_basedir restrictions."
	fi
}

php-sapi_securityupgrade() {
	if has_version "<${PF}"; then
		ewarn "This is a security upgrade for PHP!"
		ewarn "Please ensure that you apply any changes to the apache and PHP"
		ewarn "configutation files!"
	else
		einfo "This is a security upgrade for PHP!"
		einfo "However it is not critical for your machine"
	fi
}

php-sapi_warning_mssql_freetds() {
	ewarn "If you have both freetds and mssql in your USE flags, parts of PHP"
	ewarn "may not behave correctly, or may give strange warnings. You have"
	ewarn "been warned! It's recommended that you pick ONE of them. For sybase"
	ewarn "support, chose 'freetds'. For mssql support choose 'mssql'."
}
