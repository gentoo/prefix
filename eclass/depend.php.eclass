# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/depend.php.eclass,v 1.18 2007/03/05 01:50:47 chtekk Exp $

# ========================================================================
#
# depend.php.eclass
#		Functions to allow ebuilds to depend on php4 and/or php5
#
# Author:	Stuart Herbert
#			<stuart@gentoo.org>
#
# Author:	Luca Longinotti
#			<chtekk@gentoo.org>
#
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# ========================================================================

inherit eutils phpconfutils

# PHP4-only depend functions
need_php4_cli() {
	DEPEND="${DEPEND} =virtual/php-4*"
	RDEPEND="${RDEPEND} =virtual/php-4*"
	PHP_VERSION="4"
}

need_php4_httpd() {
	DEPEND="${DEPEND} =virtual/httpd-php-4*"
	RDEPEND="${RDEPEND} =virtual/httpd-php-4*"
	PHP_VERSION="4"
}

need_php4() {
	DEPEND="${DEPEND} =dev-lang/php-4*"
	RDEPEND="${RDEPEND} =dev-lang/php-4*"
	PHP_VERSION="4"
	PHP_SHARED_CAT="php4"
}

# common settings go in here
uses_php4() {
	# cache this
	libdir=$(get_libdir)

	PHPIZE="/usr/${libdir}/php4/bin/phpize"
	PHPCONFIG="/usr/${libdir}/php4/bin/php-config"
	PHPCLI="/usr/${libdir}/php4/bin/php"
	PHPCGI="/usr/${libdir}/php4/bin/php-cgi"
	PHP_PKG="`best_version =dev-lang/php-4*`"
	PHPPREFIX="/usr/${libdir}/php4"
	EXT_DIR="`${PHPCONFIG} --extension-dir 2>/dev/null`"

	einfo
	einfo "Using ${PHP_PKG}"
	einfo
}

# PHP5-only depend functions
need_php5_cli() {
	DEPEND="${DEPEND} =virtual/php-5*"
	RDEPEND="${RDEPEND} =virtual/php-5*"
	PHP_VERSION="5"
}

need_php5_httpd() {
	DEPEND="${DEPEND} =virtual/httpd-php-5*"
	RDEPEND="${RDEPEND} =virtual/httpd-php-5*"
	PHP_VERSION="5"
}

need_php5() {
	DEPEND="${DEPEND} =dev-lang/php-5*"
	RDEPEND="${RDEPEND} =dev-lang/php-5*"
	PHP_VERSION="5"
	PHP_SHARED_CAT="php5"
}

# common settings go in here
uses_php5() {
	# cache this
	libdir=$(get_libdir)

	PHPIZE="/usr/${libdir}/php5/bin/phpize"
	PHPCONFIG="/usr/${libdir}/php5/bin/php-config"
	PHPCLI="/usr/${libdir}/php5/bin/php"
	PHPCGI="/usr/${libdir}/php5/bin/php-cgi"
	PHP_PKG="`best_version =dev-lang/php-5*`"
	PHPPREFIX="/usr/${libdir}/php5"
	EXT_DIR="`${PHPCONFIG} --extension-dir 2>/dev/null`"

	einfo
	einfo "Using ${PHP_PKG}"
	einfo
}

# general PHP depend functions
need_php_cli() {
	DEPEND="${DEPEND} virtual/php"
	RDEPEND="${RDEPEND} virtual/php"
}

need_php_httpd() {
	DEPEND="${DEPEND} virtual/httpd-php"
	RDEPEND="${RDEPEND} virtual/httpd-php"
}

need_php() {
	DEPEND="${DEPEND} dev-lang/php"
	RDEPEND="${RDEPEND} dev-lang/php"
	PHP_SHARED_CAT="php"
}

need_php_by_category() {
	case "${CATEGORY}" in
		dev-php) need_php ;;
		dev-php4) need_php4 ;;
		dev-php5) need_php5 ;;
		*) die "Version of PHP required by packages in category ${CATEGORY} unknown"
	esac
}

# Call this function from your pkg_setup, src_compile and src_install methods
# if you need to know where the PHP binaries are installed and their data

has_php() {
	# If PHP_PKG is already set, then we have remembered our PHP settings
	# from last time
	if [[ -n ${PHP_PKG} ]] ; then
		return
	fi

	if [[ -z ${PHP_VERSION} ]] ; then
		# Detect which PHP version we have installed
		if has_version '=dev-lang/php-5*' ; then
			PHP_VERSION="5"
		elif has_version '=dev-lang/php-4*' ; then
			PHP_VERSION="4"
		else
			die "Unable to find an installed dev-lang/php package"
		fi
	fi

	# If we get here, then PHP_VERSION tells us which version of PHP we
	# want to use
	uses_php${PHP_VERSION}
}

# Call this function from pkg_setup if your package only works with
# specific SAPIs
#
# $1 ... a list of PHP SAPI USE flags (cli, cgi, apache, apache2)
#
# Returns if any one of the listed SAPIs have been installed
# Dies if none of the listed SAPIs have been installed

require_php_sapi_from() {
	has_php

	local has_sapi="0"
	local x

	einfo "Checking for compatible SAPI(s)"

	for x in $@ ; do
		if built_with_use =${PHP_PKG} ${x} || phpconfutils_built_with_use =${PHP_PKG} ${x} ; then
			einfo "  Discovered compatible SAPI ${x}"
			has_sapi="1"
		fi
	done

	if [[ "${has_sapi}" == "1" ]] ; then
		return
	fi

	eerror
	eerror "${PHP_PKG} needs to be re-installed with one of the following"
	eerror "USE flags enabled:"
	eerror
	eerror "  $@"
	eerror
	die "No compatible PHP SAPIs found"
}

# Call this function from pkg_setup if your package requires PHP compiled
# with specific USE flags
#
# $1 ... a list of USE flags
#
# Returns if all of the listed USE flags are enabled
# Dies if any of the listed USE flags are disabled

require_php_with_use() {
	has_php

	local missing_use=""
	local x

	einfo "Checking for required PHP feature(s) ..."

	for x in $@ ; do
		if ! built_with_use =${PHP_PKG} ${x} && ! phpconfutils_built_with_use =${PHP_PKG} ${x} ; then
			einfo "  Discovered missing USE flag: ${x}"
			missing_use="${missing_use} ${x}"
		fi
	done

	if [[ -z "${missing_use}" ]] ; then
		if [[ -z "${PHPCHECKNODIE}" ]] ; then
			return
		else
			return 0
		fi
	fi

	if [[ -z "${PHPCHECKNODIE}" ]] ; then
		eerror
		eerror "${PHP_PKG} needs to be re-installed with all of the following"
		eerror "USE flags enabled:"
		eerror
		eerror "  $@"
		eerror
		die "Missing PHP USE flags found"
	else
		return 1
	fi
}

# Call this function from pkg_setup if your package requires PHP compiled
# with any of specified USE flags
#
# $1 ... a list of USE flags
#
# Returns if any of the listed USE flags are enabled
# Dies if all of the listed USE flags are disabled

require_php_with_any_use() {
	has_php

	local missing_use=""
	local x

	einfo "Checking for required PHP feature(s) ..."

	for x in $@ ; do
		if built_with_use =${PHP_PKG} ${x} || phpconfutils_built_with_use =${PHP_PKG} ${x} ; then
			einfo "  USE flag ${x} is enabled, ok ..."
			return
		else
			missing_use="${missing_use} ${x}"
		fi
	done

	if [[ -z "${missing_use}" ]] ; then
		if [[ -z "${PHPCHECKNODIE}" ]] ; then
			return
		else
			return 0
		fi
	fi

	if [[ -z "${PHPCHECKNODIE}" ]] ; then
		eerror
		eerror "${PHP_PKG} needs to be re-installed with any of the following"
		eerror "USE flags enabled:"
		eerror
		eerror "  $@"
		eerror
		die "Missing PHP USE flags found"
	else
		return 1
	fi
}

# ========================================================================
# has_*() functions
#
# These functions return 0 if the condition is satisfied, 1 otherwise
# ========================================================================

# Check if our PHP was compiled with ZTS (Zend Thread Safety) enabled

has_zts() {
	has_php

	if built_with_use =${PHP_PKG} apache2 threads || phpconfutils_built_with_use =${PHP_PKG} apache2 threads ; then
		return 0
	fi

	return 1
}

# Check if our PHP was built with debug support enabled

has_debug() {
	has_php

	if built_with_use =${PHP_PKG} debug || phpconfutils_built_with_use =${PHP_PKG} debug ; then
		return 0
	fi

	return 1
}

# Check if our PHP was built with the concurrentmodphp support enabled

has_concurrentmodphp() {
	has_php

	if built_with_use =${PHP_PKG} apache2 concurrentmodphp || phpconfutils_built_with_use =${PHP_PKG} apache2 concurrentmodphp ; then
		return 0
	fi

	return 1
}

# ========================================================================
# require_*() functions
#
# These functions die() if PHP was built without the required features
# ========================================================================

# Require a PHP built with PDO support (PHP5 only)

require_pdo() {
	has_php

	# Do we have PHP5 installed?
	if [[ "${PHP_VERSION}" == "4" ]] ; then
		eerror
		eerror "This package requires PDO."
		eerror "PDO is only available for PHP 5."
		eerror "You must install >=dev-lang/php-5.1 with"
		eerror "either the 'pdo' or the 'pdo-external'"
		eerror "USE flags turned on."
		eerror
		die "PHP 5 not installed"
	fi

	# Was PHP5 compiled with internal PDO support?
	if built_with_use =${PHP_PKG} pdo || phpconfutils_built_with_use =${PHP_PKG} pdo ; then
		return
	fi

	# Ok, maybe PDO was built as an external extension?
	if ( built_with_use =${PHP_PKG} pdo-external || phpconfutils_built_with_use =${PHP_PKG} pdo-external ) && has_version 'dev-php5/pecl-pdo' ; then
		return
	fi

	# Ok, as last resort, it suffices that pecl-pdo was installed to have PDO support
	if has_version 'dev-php5/pecl-pdo' ; then
		return
	fi

	# If we get here, then we don't have PDO support
	eerror
	eerror "No PDO extension for PHP found."
	eerror "Please note that PDO only exists for PHP 5."
	eerror "Please install a PDO extension for PHP 5,"
	eerror "you must install >=dev-lang/php-5.1 with"
	eerror "either the 'pdo' or the 'pdo-external'"
	eerror "USE flags turned on."
	eerror
	die "No PDO extension for PHP 5 found"
}

# Determines which installed PHP version has the CLI SAPI enabled,
# useful for PEAR stuff, or anything which needs to run PHP
# scripts depending on the CLI SAPI

require_php_cli() {
	# If PHP_PKG is set, then we have remembered our PHP settings
	# from last time
	if [[ -n ${PHP_PKG} ]] ; then
		return
	fi

	local PHP_PACKAGE_FOUND=""

	# Detect which PHP version we have installed
	if has_version '=dev-lang/php-4*' ; then
		PHP_PACKAGE_FOUND="1"
		pkg="`best_version '=dev-lang/php-4*'`"
		if built_with_use =${pkg} cli || phpconfutils_built_with_use =${pkg} cli ; then
			PHP_VERSION="4"
		fi
	fi

	if has_version '=dev-lang/php-5*' ; then
		PHP_PACKAGE_FOUND="1"
		pkg="`best_version '=dev-lang/php-5*'`"
		if built_with_use =${pkg} cli || phpconfutils_built_with_use =${pkg} cli ; then
			PHP_VERSION="5"
		fi
	fi

	if [[ -z ${PHP_PACKAGE_FOUND} ]] ; then
		die "Unable to find an installed dev-lang/php package"
	fi

	if [[ -z ${PHP_VERSION} ]] ; then
		die "No PHP CLI installed"
	fi

	# If we get here, then PHP_VERSION tells us which version of PHP we
	# want to use
	uses_php${PHP_VERSION}
}

# Determines which installed PHP version has the CGI SAPI enabled,
# useful for anything which needs to run PHP scripts
# depending on the CGI SAPI

require_php_cgi() {
	# If PHP_PKG is set, then we have remembered our PHP settings
	# from last time
	if [[ -n ${PHP_PKG} ]] ; then
		return
	fi

	local PHP_PACKAGE_FOUND=""

	# Detect which PHP version we have installed
	if has_version '=dev-lang/php-4*' ; then
		PHP_PACKAGE_FOUND="1"
		pkg="`best_version '=dev-lang/php-4*'`"
		if built_with_use =${pkg} cgi || phpconfutils_built_with_use =${pkg} cgi ; then
			PHP_VERSION="4"
		fi
	fi

	if has_version '=dev-lang/php-5*' ; then
		PHP_PACKAGE_FOUND="1"
		pkg="`best_version '=dev-lang/php-5*'`"
		if built_with_use =${pkg} cgi || phpconfutils_built_with_use =${pkg} cgi ; then
			PHP_VERSION="5"
		fi
	fi

	if [[ -z ${PHP_PACKAGE_FOUND} ]] ; then
		die "Unable to find an installed dev-lang/php package"
	fi

	if [[ -z ${PHP_VERSION} ]] ; then
		die "No PHP CGI installed"
	fi

	# If we get here, then PHP_VERSION tells us which version of PHP we
	# want to use
	uses_php${PHP_VERSION}
}

# Require a PHP built with SQLite support

require_sqlite() {
	has_php

	# Has our PHP been built with SQLite support?
	if built_with_use =${PHP_PKG} sqlite || phpconfutils_built_with_use =${PHP_PKG} sqlite ; then
		return
	fi

	# Do we have pecl-sqlite installed for PHP4?
	if [[ "${PHP_VERSION}" == "4" ]] ; then
		if has_version 'dev-php4/pecl-sqlite' ; then
			return
		fi
	fi

	# If we get here, then we don't have any SQLite support for PHP installed
	eerror
	eerror "No SQLite extension for PHP found."
	eerror "Please install an SQLite extension for PHP,"
	eerror "this is done best by simply adding the"
	eerror "'sqlite' USE flag when emerging dev-lang/php."
	eerror
	die "No SQLite extension for PHP found"
}

# Require a PHP built with GD support

require_gd() {
	has_php

	# Do we have the internal GD support installed?
	if built_with_use =${PHP_PKG} gd || phpconfutils_built_with_use =${PHP_PKG} gd ; then
		return
	fi

	# Ok, maybe GD was built using the external library support?
	if built_with_use =${PHP_PKG} gd-external || phpconfutils_built_with_use =${PHP_PKG} gd-external ; then
		return
	fi

	# If we get here, then we have no GD support
	eerror
	eerror "No GD support for PHP found."
	eerror "Please install the GD support for PHP,"
	eerror "you must install dev-lang/php with either"
	eerror "the 'gd' or the 'gd-external' USE flags"
	eerror "turned on."
	eerror
	die "No GD support found for PHP"
}

# ========================================================================
# Misc functions
#
# These functions provide miscellaneous checks and functionality.
# ========================================================================

# Executes some checks needed when installing a binary PHP extension

php_binary_extension() {
	has_php

	local PUSE_ENABLED=""

	# Binary extensions do not support the change of PHP
	# API version, so they can't be installed when USE flags
	# are enabled which change the PHP API version, they also
	# don't provide correctly versioned symbols for our use

	if has_debug ; then
		eerror
		eerror "You cannot install binary PHP extensions"
		eerror "when the 'debug' USE flag is enabled!"
		eerror "Please reemerge dev-lang/php with the"
		eerror "'debug' USE flag turned off."
		eerror
		PUSE_ENABLED="1"
	fi

	if has_concurrentmodphp ; then
		eerror
		eerror "You cannot install binary PHP extensions when"
		eerror "the 'concurrentmodphp' USE flag is enabled!"
		eerror "Please reemerge dev-lang/php with the"
		eerror "'concurrentmodphp' USE flag turned off."
		eerror
		PUSE_ENABLED="1"
	fi

	if [[ -n ${PUSE_ENABLED} ]] ; then
		die "'debug' and/or 'concurrentmodphp' USE flags turned on!"
	fi
}

# Alternative to dodoc function for use in our PHP eclasses and
# ebuilds.
# Stored here because depend.php gets always sourced everywhere
# in the PHP ebuilds and eclasses.
# It simply is dodoc with a changed path to the docs.
# NOTE: no support for docinto is given!

dodoc-php() {
if [[ $# -lt 1 ]] ; then
	echo "$0: at least one argument needed" 1>&2
	exit 1
fi

phpdocdir="${D}/usr/share/doc/${CATEGORY}/${PF}/"

if [[ ! -d "${phpdocdir}" ]] ; then
	install -d "${phpdocdir}"
fi

for x in $@ ; do
	if [[ -s "${x}" ]] ; then
		install -m0644 "${x}" "${phpdocdir}"
		gzip -f -9 "${phpdocdir}/${x##*/}"
	elif [[ ! -e "${x}" ]] ; then
		echo "dodoc-php: ${x} does not exist" 1>&2
	fi
done
}
